require 'spec_helper'

describe FlickrUpdater do
  describe '#update_everything' do
    it "does some work" do
      mock_clear_page_cache 2
      stub(FlickrService.instance).groups_get_info('group_id' => FlickrService::GROUP_ID) { {
        'group'=> [ {
          'members' => [ '1492' ]
        } ]
      } }
      update = FlickrUpdate.make member_count: 1492
      mock(FlickrUpdate).create!(member_count: '1492') { update }
      mock(FlickrUpdater).update_all_photos { [ 1, 2, 3, 4 ] }
      mock(FlickrUpdater).update_all_people
      stub(Time).now { Time.utc(2011) }
      mock(update).update_attribute :completed_at, Time.utc(2011)
      FlickrUpdater.update_everything.should == "Created 1 new photos and 2 new users. Got 3 pages out of 4."
    end
  end

  describe '.update_all_people' do
    it "updates an existing user's username and pathalias" do
      person = Person.make username: 'old_username', pathalias: 'new_pathalias'
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
      stub(FlickrService.instance).photos_get_favorites(
        'photo_id' => 'incoming_photo_flickrid', 'per_page' => '50', 'page' => '1') { {
        'stat' => 'ok',
        'photo' => [ {
          'person' => [
            {}, {}, {}, {}, {}, {}, {}
          ]
        } ]
      } }
    end

    it "gets the state of the group's photos from Flickr and stores it" do
      stub_get_photos
      stub_get_faves
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
      stub(Time).now { Time.utc 2014 }
      person = Person.make flickrid: 'incoming_person_flickrid'
      photo_before = Photo.make \
        person: person,
        flickrid: 'incoming_photo_flickrid',
        farm: '1',
        server: 'old_server',
        secret: 'old_secret',
        latitude: 37.654321,
        latitude: -122.123456,
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

    it "doesn't update faves if Flickr says the photo hasn't been updated" do
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
      stub(Time).now { Time.utc 2014 }
      person = Person.make flickrid: 'incoming_person_flickrid'
      photo_before = Photo.make \
        person: person,
        flickrid: 'incoming_photo_flickrid',
        farm: '1',
        server: 'old_server',
        secret: 'old_secret',
        latitude: 37.654321,
        latitude: -122.123456,
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
      stub(FlickrUpdater).faves_from_flickr { raise FlickrService::FlickrRequestFailedError }
      FlickrUpdater.update_all_photos
      Photo.first.faves.should == 0
    end

    it "leaves an existing photo's faves alone if the request for faves fails" do
      stub_get_photos
      stub(FlickrUpdater).faves_from_flickr { raise FlickrService::FlickrRequestFailedError }
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
    before do
      @photo = Photo.make
    end

    it "loads comments from Flickr" do
      stub_get_faves
      stub_request_to_return_one_comment
      FlickrUpdater.update_photo @photo
      @photo.faves.should == 7
      photo_has_the_comment_from_the_request
    end

    it "deletes previous comments" do
      Comment.make 'previous', photo: @photo
      stub_get_faves
      stub_request_to_return_one_comment
      FlickrUpdater.update_photo @photo
      photo_has_the_comment_from_the_request
    end

    it "does not delete previous comments if the photo currently has no comments" do
      Comment.make 'previous', photo: @photo
      stub_get_faves
      stub(FlickrService.instance).photos_comments_get_list { {
        'comments' => [ {
        } ]
      } }
      FlickrUpdater.update_photo @photo
      @photo.comments.length.should == 1
      Comment.count.should == 1
    end

    it "leaves previous comments alone if the request for comments fails" do
      Comment.make 'previous', photo: @photo
      stub_get_faves
      stub(FlickrService.instance).photos_comments_get_list { raise FlickrService::FlickrRequestFailedError }
      FlickrUpdater.update_photo @photo
      Comment.count.should == 1
    end

    def stub_get_faves
      # noinspection RubyArgCount
      stub(FlickrService.instance).photos_get_favorites(
        'photo_id' => @photo.flickrid, 'per_page' => '50', 'page' => '1') { {
        'stat' => 'ok',
        'photo' => [ {
          'person' => [
            {}, {}, {}, {}, {}, {}, {}
          ]
        } ]
      } }
    end

    def stub_request_to_return_one_comment
      # noinspection RubyArgCount
      stub(FlickrService.instance).photos_comments_get_list { {
        'comments' => [ {
          'comment' => [ {
            'author' => 'commenter_flickrid',
            'authorname' => 'commenter_username',
            'content' => 'comment text'
          } ]
        } ]
      } }
    end

    def photo_has_the_comment_from_the_request
      @photo.comments.length.should == 1
      comment = @photo.comments[0]
      comment.flickrid.should == 'commenter_flickrid'
      comment.username.should == 'commenter_username'
      comment.comment_text.should == 'comment text'
    end

  end

end
