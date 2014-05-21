require 'spec_helper'

describe FlickrUpdater do
  describe '#update_everything' do
    it "does some work" do
      mock_clear_page_cache 2
      stub(FlickrService.instance).groups_get_info(group_id: FlickrService::GROUP_ID) { {
        'group'=> [ {
          'members' => [ '1492' ]
        } ]
      } }
      mock(FlickrUpdater).update_all_photos { [ 1, 2, 3, 4 ] }
      mock(FlickrUpdater).update_all_people
      stub(Time).now { Time.utc(2011) }
      FlickrUpdater.update_everything.should == "Created 1 new photos and 2 new users. Got 3 pages out of 4."
      updates = FlickrUpdate.all
      updates.length.should == 1
      update = updates.first
      update.member_count.should == 1492
      update.completed_at.should == Time.utc(2011)
    end
  end

  ### People

  describe '.update_all_people' do
    it "updates an existing user's username and pathalias" do
      person = Person.make username: 'old_username', pathalias: 'old_pathalias'
      stub(FlickrService.instance).people_get_info { {
        'person' => [ {
          'username' => [ 'new_username' ],
          'photosurl' => [ 'https://www.flickr.com/photos/new_pathalias/' ]
        } ]
      } }
      FlickrUpdater.update_all_people
      person.reload
      person.username.should == 'new_username'
      person.pathalias.should == 'new_pathalias'
    end
  end

  ### Photos

  describe '.update_all_photos' do
    def stub_get_photos
      # noinspection RubyArgCount
      stub(FlickrService.instance).groups_pools_get_photos { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'incoming_photo_flickrid',
            'owner' => 'incoming_person_flickrid',
            'ownername' => 'incoming_username',
            'pathalias' => 'incoming_pathalias',
            'farm' => '1',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '37.123456',
            'longitude' => '-122.654321',
            'accuracy' => '16',
            'lastupdate' => Time.utc(2011, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
    end

    def stub_get_faves
      # noinspection RubyArgCount
      stub(FlickrUpdater).fave_count('incoming_photo_flickrid') { 7 }
    end

    # TODO Dave after tags have been collected once in production, merge the following two methods into one

    def mock_get_comments
      # noinspection RubyArgCount
      mock(FlickrUpdater).update_comments is_a(Photo)
    end

    def mock_get_tags
      # noinspection RubyArgCount
      mock(FlickrUpdater).update_tags is_a(Photo)
    end

    it "gets the state of the group's photos from Flickr and stores it" do
      stub_get_photos
      stub_get_faves
      mock_get_comments
      mock_get_tags
      stub(Time).now { Time.utc 2014 }
      FlickrUpdater.update_all_photos.should == [ 1, 1, 1, 1 ]

      photos = Photo.includes :person
      photos.size.should == 1
      photo = photos[0]
      person = photo.person

      person.flickrid.should == 'incoming_person_flickrid'
      person.username.should == 'incoming_username'
      person.pathalias.should == 'incoming_pathalias'

      photo.flickrid.should == 'incoming_photo_flickrid'
      photo.farm.should == '1'
      photo.server.should == 'incoming_server'
      photo.secret.should == 'incoming_secret'
      photo.latitude.should == 37.123456
      photo.longitude.should == -122.654321
      photo.accuracy.should == 16
      photo.dateadded.should == Time.utc(2011)
      photo.lastupdate.should == Time.utc(2011, 1, 1, 1)
      photo.views.should == 50
      photo.faves.should == 7
      photo.seen_at.should == Time.utc(2014)

    end

    # The response from this API call needs to be fixed up in this way. That from people.get.info does not.
    it "replaces an empty-string pathalias with the person's flickrid" do
      stub(FlickrService.instance).groups_pools_get_photos { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'incoming_photo_flickrid',
            'owner' => 'incoming_person_flickrid',
            'ownername' => 'incoming_username',
            'pathalias' => '',
            'farm' => '1',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '37.123456',
            'longitude' => '-122.654321',
            'accuracy' => '16',
            'lastupdate' => Time.utc(2011, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
      stub_get_faves
      mock_get_comments
      mock_get_tags
      FlickrUpdater.update_all_photos.should == [ 1, 1, 1, 1 ]
      people = Person.all
      people.size.should == 1
      person = people[0]
      person.flickrid.should == 'incoming_person_flickrid'
      person.username.should == 'incoming_username'
      person.pathalias.should == 'incoming_person_flickrid'
    end

    it "uses an existing person" do
      stub_get_photos
      stub_get_faves
      mock_get_comments
      mock_get_tags
      person_before = Person.make flickrid: 'incoming_person_flickrid', username: 'old_username', pathalias: 'incoming_person_pathalias'
      FlickrUpdater.update_all_photos.should == [ 1, 0, 1, 1 ]
      people = Person.all
      people.size.should == 1
      person_after = people[0]
      person_after.id.should == person_before.id
      person_after.flickrid.should == person_before.flickrid
      # The following two assertions document that a username or pathalias that changes during the update is not updated
      person_after.username.should == person_before.username
      person_after.pathalias.should == person_before.pathalias
    end

    it "uses an existing photo, and updates attributes that changed" do
      stub_get_photos
      stub_get_faves
      mock_get_comments
      mock_get_tags
      stub(Time).now { Time.utc 2014 }
      person = Person.make flickrid: 'incoming_person_flickrid'
      photo_before = Photo.make \
        person: person,
        flickrid: 'incoming_photo_flickrid',
        farm: '1',
        server: 'old_server',
        secret: 'old_secret',
        latitude: 37.654321,
        longitude: -122.123456,
        accuracy: 15,
        dateadded: Time.utc(2010),
        lastupdate: Time.utc(2010, 1, 1, 1),
        views: 40,
        faves: 6
      FlickrUpdater.update_all_photos.should == [ 0, 0, 1, 1 ]
      photos = Photo.all
      photos.size.should == 1
      photo_after = photos[0]
      photo_after.id.should == photo_before.id
      photo_after.flickrid.should == photo_before.flickrid
      photo_after.farm.should == '1'
      photo_after.server.should == 'incoming_server'
      photo_after.secret.should == 'incoming_secret'
      photo_after.latitude.should == 37.123456
      photo_after.longitude.should == -122.654321
      photo_after.accuracy.should == 16
      # Note that dateadded is not updated
      photo_after.dateadded.should == Time.utc(2010)
      photo_after.lastupdate.should == Time.utc(2011, 1, 1, 1)
      photo_after.views.should == 50
      photo_after.faves.should == 7
      photo_after.seen_at.should == Time.utc(2014)
    end

    it "doesn't update faves, comments or tags if Flickr says the photo hasn't been updated" do
      stub(FlickrService.instance).groups_pools_get_photos { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'incoming_photo_flickrid',
            'owner' => 'incoming_person_flickrid',
            'ownername' => 'incoming_username',
            'pathalias' => 'incoming_pathalias',
            'farm' => '1',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '37.123456',
            'longitude' => '-122.654321',
            'accuracy' => '16',
            'lastupdate' => Time.utc(2010, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
      dont_allow(FlickrService.instance).fave_count
      dont_allow(FlickrUpdater).update_comments
      mock_get_tags # TODO Dave dont_allow update_tags after tags have been updated in production
      stub(Time).now { Time.utc 2014 }
      person = Person.make flickrid: 'incoming_person_flickrid'
      photo_before = Photo.make \
        person: person,
        flickrid: 'incoming_photo_flickrid',
        farm: '1',
        server: 'old_server',
        secret: 'old_secret',
        latitude: 37.654321,
        longitude: -122.123456,
        accuracy: 15,
        dateadded: Time.utc(2010),
        lastupdate: Time.utc(2010, 1, 1, 1),
        views: 40,
        faves: 6
      FlickrUpdater.update_all_photos.should == [ 0, 0, 1, 1 ]
      photos = Photo.all
      photos.size.should == 1
      photo_after = photos[0]
      photo_after.id.should == photo_before.id
      photo_after.flickrid.should == photo_before.flickrid
      photo_after.farm.should == '1'
      photo_after.server.should == 'incoming_server'
      photo_after.secret.should == 'incoming_secret'
      photo_after.latitude.should == 37.123456
      photo_after.longitude.should == -122.654321
      photo_after.accuracy.should == 16
      photo_after.dateadded.should == Time.utc(2010)
      photo_after.lastupdate.should == Time.utc(2010, 1, 1, 1)
      photo_after.views.should == 50
      photo_after.faves.should == 6
      photo_after.seen_at.should == Time.utc(2014)
    end

    it "sets a new photo's faves to 0 if the request for faves fails" do
      stub_get_photos
      mock_get_comments
      mock_get_tags
      stub(FlickrUpdater).fave_count { raise FlickrService::FlickrRequestFailedError }
      FlickrUpdater.update_all_photos
      Photo.first.faves.should == 0
    end

    it "leaves an existing photo's faves alone if the request for faves fails" do
      stub_get_photos
      mock_get_comments
      mock_get_tags
      stub(FlickrUpdater).fave_count { raise FlickrService::FlickrRequestFailedError }
      photo_before = Photo.make faves: 6
      FlickrUpdater.update_all_photos
      Photo.first.faves.should == 6
    end

    it "stores 0 latitude, longitude and accuracy as nil" do
      stub(FlickrService.instance).groups_pools_get_photos { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'incoming_photo_flickrid',
            'owner' => 'incoming_person_flickrid',
            'ownername' => 'incoming_username',
            'farm' => '0',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '0',
            'longitude' => '0',
            'accuracy' => '0',
            'lastupdate' => Time.utc(2011, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
      stub_get_faves
      mock_get_comments
      mock_get_tags
      FlickrUpdater.update_all_photos.should == [ 1, 1, 1, 1 ]
      photos = Photo.all
      photos.size.should == 1
      photo = photos[0]
      photo.latitude.should be_nil
      photo.longitude.should be_nil
      photo.accuracy.should be_nil
    end

  end

  describe '.update_photo' do
    it "loads comments from Flickr" do
      photo = Photo.make
      stub(FlickrUpdater).fave_count(photo.flickrid) { 7 }
      mock(FlickrUpdater).update_comments photo
      FlickrUpdater.update_photo photo
      photo.faves.should == 7
    end
  end

  describe '.fave_count' do
    it "returns the number of faves that the photo has" do
      # noinspection RubyArgCount
      stub(FlickrService.instance).photos_get_favorites(photo_id: 'photo_flickrid', per_page: 1) { {
        'stat' => 'ok',
        'photo' => [ { 'total' => '7'} ]
      } }
      FlickrUpdater.fave_count('photo_flickrid').should == 7
    end
  end

  describe '.update_comments' do
    let(:photo) { Photo.make }

    it "loads comments from Flickr" do
      stub_request_to_return_one_comment
      FlickrUpdater.update_comments photo
      photo_has_the_comment_from_the_request
    end

    it "deletes previous comments" do
      Comment.make 'previous', photo: photo
      stub_request_to_return_one_comment
      FlickrUpdater.update_comments photo
      photo_has_the_comment_from_the_request
    end

    it "does not delete previous comments if the photo currently has no comments" do
      Comment.make 'previous', photo: photo
      stub(FlickrService.instance).photos_comments_get_list { {
        'comments' => [ {
        } ]
      } }
      FlickrUpdater.update_comments photo
      photo.comments.length.should == 1
      Comment.count.should == 1
    end

    it "leaves previous comments alone if the request for comments fails" do
      Comment.make 'previous', photo: photo
      stub(FlickrService.instance).photos_comments_get_list { raise FlickrService::FlickrRequestFailedError }
      FlickrUpdater.update_comments photo
      Comment.count.should == 1
    end

    def stub_request_to_return_one_comment
      # noinspection RubyArgCount
      stub(FlickrService.instance).photos_comments_get_list(photo_id: 'photo_flickrid') { {
        'comments' => [ {
          'comment' => [ {
            'author' => 'commenter_flickrid',
            'authorname' => 'commenter_username',
            'content' => 'comment text',
            'datecreate' => '1356998400'
          } ]
        } ]
      } }
    end

    def photo_has_the_comment_from_the_request
      photo.comments.length.should == 1
      comment = photo.comments[0]
      comment.flickrid.should == 'commenter_flickrid'
      comment.username.should == 'commenter_username'
      comment.comment_text.should == 'comment text'
      comment.commented_at.should == Time.utc(2013)
    end

  end

  describe '.update_tags' do
    let(:photo) { create :photo }

    it "loads tags from Flickr" do
      stub_get_tags Tag.new(raw: 'Tag 1'), Tag.new(raw: 'Tag 2', machine_tag: true)
      FlickrUpdater.update_tags photo
      photo.tags.map { |tag| [tag.raw, tag.machine_tag] }.should =~ [['Tag 1', false], ['Tag 2', true]]
    end

    it "deletes previous tags" do
      create :tag, photo: photo, raw: 'old tag'
      stub_get_tags Tag.new(raw: 'new tag')
      FlickrUpdater.update_tags photo
      photo.tags.map(&:raw).should == ['new tag']
    end

    it "deletes previous tags if the photo currently has no tags" do
      create :tag, photo: photo, raw: 'old tag'
      stub(FlickrService.instance).tags_get_list_photo(photo_id: photo.flickrid) { {
        'photo' => [ {
          'tags' => [ {
          } ]
        } ]
      } }
      FlickrUpdater.update_tags photo
      photo.tags.should be_empty
    end

    it "leaves previous tags alone if the request for tags fails" do
      create :tag, photo: photo, raw: 'old tag'
      stub(FlickrService.instance).tags_get_list_photo(photo_id: photo.flickrid) { raise FlickrService::FlickrRequestFailedError }
      FlickrUpdater.update_tags photo
      photo.tags.map(&:raw).should == ['old tag']
    end

    def stub_get_tags(*tags)
      # noinspection RubyArgCount
      stub(FlickrService.instance).tags_get_list_photo(photo_id: photo.flickrid) { {
        'photo' => [ {
          'tags' => [ {
            'tag' => tags.map { |tag| { 'raw' => tag.raw, 'machine_tag' => (tag.machine_tag ? 1 : 0).to_s } }
          } ]
        } ]
      } }
    end

  end

end
