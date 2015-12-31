describe FlickrUpdater do
  describe '#update_everything' do
    it "does some work" do
      mock_clear_page_cache 2
      allow(FlickrService.instance).to receive(:groups_get_info).with(group_id: FlickrService::GROUP_ID) do
        {
          'group' => [{
            'members' => ['1492']
          }]
        }
      end
      expect(FlickrUpdater).to receive(:update_all_photos) { [ 1, 2, 3, 4 ] }
      expect(FlickrUpdater).to receive(:update_all_people)
      allow(Time).to receive(:now) { Time.utc(2011) }
      expect(FlickrUpdater.update_everything).to eq("Created 1 new photos and 2 new users. Got 3 pages out of 4.")
      update = FlickrUpdate.first_and_only
      expect(update.member_count).to eq(1492)
      expect(update.completed_at).to eq(Time.utc(2011))
    end
  end

  ### People

  describe '.update_all_people' do
    it "updates an existing user's username and pathalias" do
      person = create :person, username: 'old_username', pathalias: 'old_pathalias'
      allow(FlickrService.instance).to receive(:people_get_info) do
        {
          'person' => [{
            'username' => ['new_username'],
            'photosurl' => ['https://www.flickr.com/photos/new_pathalias/']
          }]
        }
      end
      FlickrUpdater.update_all_people
      person.reload
      expect(person.username).to eq('new_username')
      expect(person.pathalias).to eq('new_pathalias')
    end

    it "handles an error" do
      person = create :person, username: 'old_username', pathalias: 'old_pathalias'
      allow(FlickrService.instance).to receive(:people_get_info) do
        raise FlickrService::FlickrRequestFailedError, "Couldn't get info from Flickr"
      end
      FlickrUpdater.update_all_people
      person.reload
      expect(person.username).to eq('old_username')
      expect(person.pathalias).to eq('old_pathalias')
    end

  end

  ### Photos

  describe '.update_all_photos' do
    let!(:now) { Time.utc 2014 }

    before do
      allow(Time).to receive(:now) { now }
    end

    def stub_get_photos(opts = {}, stub_opts = {})
      stubbed_photo =
        {
          id: 'incoming_photo_flickrid',
          owner: 'incoming_person_flickrid',
          ownername: 'incoming_username',
          pathalias: 'incoming_pathalias',
          farm: '1',
          server: 'incoming_server',
          secret: 'incoming_secret',
          datetaken: Time.local(2010), # local because we assume that the photo was taken in SF
          dateadded: Time.utc(2011),
          latitude: 37.123456,
          longitude: -122.654321,
          accuracy: 16,
          lastupdate: Time.utc(2011, 1, 1, 1),
          views: 50,
          title: 'The title',
          description: 'The description'
        }.merge opts
      allow(FlickrService.instance).to receive(:groups_pools_get_photos) do
        {
          'photos' => [{
            'pages' => '1',
            'photo' => [{
              'id' => stubbed_photo[:id],
              'owner' => stubbed_photo[:owner],
              'ownername' => stubbed_photo[:ownername],
              'pathalias' => stubbed_photo[:pathalias],
              'farm' => stubbed_photo[:farm],
              'server' => stubbed_photo[:server],
              'secret' => stubbed_photo[:secret],
              'datetaken' => stubbed_photo[:datetaken].strftime("%Y-%m-%d %H-%M-%S"),
              'dateadded' => stubbed_photo[:dateadded].to_i.to_s,
              'latitude' => stubbed_photo[:latitude].to_s,
              'longitude' => stubbed_photo[:longitude].to_s,
              'accuracy' => stubbed_photo[:accuracy].to_s,
              'lastupdate' => stubbed_photo[:lastupdate].to_i.to_s,
              'views' => stubbed_photo[:views].to_s,
              'title' => stubbed_photo[:title],
              'description' => [stubbed_photo[:description]]
            }.merge(stub_opts)]
          }]
        }
      end
      stubbed_photo
    end

    def stub_get_faves
      allow(FlickrUpdater).to receive(:fave_count).with('incoming_photo_flickrid') { 7 }
      7
    end

    def mock_get_comments_and_tags
      expect(FlickrUpdater).to receive(:update_comments).with an_instance_of(Photo)
      expect(FlickrUpdater).to receive(:update_tags).with an_instance_of(Photo)
    end

    it "gets the state of the group's photos from Flickr and stores it" do
      stubbed_photo = stub_get_photos
      stubbed_faves = stub_get_faves
      mock_get_comments_and_tags
      expect(FlickrUpdater.update_all_photos).to eq([ 1, 1, 1, 1 ])

      photo = Photo.first_and_only

      expect(photo.person).to have_attributes(
        flickrid: stubbed_photo[:owner],
        username: stubbed_photo[:ownername],
        pathalias: stubbed_photo[:pathalias]
      )

      expect(photo).to have_attributes(
        flickrid: stubbed_photo[:id],
        farm: stubbed_photo[:farm],
        server: stubbed_photo[:server],
        secret: stubbed_photo[:secret],
        latitude: stubbed_photo[:latitude],
        longitude: stubbed_photo[:longitude],
        accuracy: stubbed_photo[:accuracy],
        datetaken: stubbed_photo[:datetaken],
        dateadded: stubbed_photo[:dateadded],
        lastupdate: stubbed_photo[:lastupdate],
        views: stubbed_photo[:views],
        title: stubbed_photo[:title],
        description: stubbed_photo[:description],
        faves: stubbed_faves,
        seen_at: now
      )

    end

    # The response from this API call needs to be fixed up in this way. That from people.get.info does not.
    it "replaces an empty-string pathalias with the person's flickrid" do
      stubbed_photo = stub_get_photos pathalias: ''
      stub_get_faves
      mock_get_comments_and_tags
      FlickrUpdater.update_all_photos

      expect(Person.first_and_only).to have_attributes(
        flickrid: stubbed_photo[:owner],
        username: stubbed_photo[:ownername],
        pathalias: stubbed_photo[:owner]
      )

    end

    it "uses an existing person" do
      stubbed_photo = stub_get_photos
      stub_get_faves
      mock_get_comments_and_tags
      person_before = create :person, flickrid: stubbed_photo[:owner]
      expect(FlickrUpdater.update_all_photos).to eq([ 1, 0, 1, 1 ])

      # Note that a username or pathalias that changes during the update is not updated
      expect(Person.first_and_only).to have_the_same_attributes_as(person_before)

    end

    # At this writing four photos have this or another invalid datetaken, structurally but not numerically correct
    it "handles an invalid datetaken" do
      stub_get_photos({}, 'datetaken' => "0000-00-00 00:00:00")
      stub_get_faves
      mock_get_comments_and_tags
      FlickrUpdater.update_all_photos
      expect(Photo.first_and_only.datetaken).to be_nil
    end

    it "propagates errors other than that which comes from an invalid datetime" do
      stub_get_photos
      allow(ActiveSupport::TimeZone['Pacific Time (US & Canada)']).to receive(:parse) { raise ArgumentError, "some other error" }
      expect { FlickrUpdater.update_all_photos }.to raise_error(ArgumentError, "some other error")
    end

    it "handles an empty description" do
      stub_get_photos description: {}
      stub_get_faves
      mock_get_comments_and_tags
      FlickrUpdater.update_all_photos
      expect(Photo.first_and_only.description).to be_nil
    end

    it "uses an existing photo, and updates attributes that changed" do
      stubbed_photo = stub_get_photos
      stubbed_faves = stub_get_faves
      mock_get_comments_and_tags
      person = create :person, flickrid: 'incoming_person_flickrid'
      photo_before = create :photo,
        person: person,
        flickrid: 'incoming_photo_flickrid',
        farm: '2',
        server: 'old_server',
        secret: 'old_secret',
        latitude: 37.654321,
        longitude: -122.123456,
        accuracy: 15,
        datetaken: Time.utc(2009),
        dateadded: Time.utc(2010),
        lastupdate: Time.utc(2010, 1, 1, 1),
        views: 40,
        faves: 6
      expect(FlickrUpdater.update_all_photos).to eq([ 0, 0, 1, 1 ])

      expect(Photo.first_and_only).to have_attributes(
        id: photo_before.id,
        flickrid: photo_before.flickrid,
        farm: stubbed_photo[:farm],
        server: stubbed_photo[:server],
        secret: stubbed_photo[:secret],
        latitude: stubbed_photo[:latitude],
        longitude: stubbed_photo[:longitude],
        accuracy: stubbed_photo[:accuracy],
        datetaken: stubbed_photo[:datetaken],
        # Set dateadded only when a photo is created, so that if a photo is added to the group,
        # removed from the group and added to the group again it retains its original dateadded.
        dateadded: photo_before.dateadded,
        lastupdate: stubbed_photo[:lastupdate],
        views: stubbed_photo[:views],
        title: stubbed_photo[:title],
        description: stubbed_photo[:description],
        faves: stubbed_faves,
        seen_at: now
      )

    end

    it "doesn't update anything except seen_at if Flickr says the photo hasn't been updated" do
      stubbed_photo = stub_get_photos lastupdate: Time.utc(2010, 1, 1, 1)
      expect(FlickrUpdater).not_to receive(:update_comments)
      expect(FlickrUpdater).not_to receive(:update_tags)
      person = create :person, flickrid: 'incoming_person_flickrid'
      photo_before = create :photo,
        person: person,
        flickrid: stubbed_photo[:id],
        farm: '2',
        server: 'old_server',
        secret: 'old_secret',
        latitude: 37.654321,
        longitude: -122.123456,
        accuracy: 15,
        datetaken: Time.utc(2009),
        dateadded: Time.utc(2010),
        lastupdate: Time.utc(2010, 1, 1, 1),
        views: 40,
        faves: 6
      FlickrUpdater.update_all_photos

      expect(Photo.first_and_only).to have_attributes(
        id: photo_before.id,
        flickrid: photo_before.flickrid,
        farm: photo_before.farm,
        server: photo_before.server,
        secret: photo_before.secret,
        latitude: photo_before.latitude,
        longitude: photo_before.longitude,
        accuracy: photo_before.accuracy,
        datetaken: photo_before.datetaken,
        dateadded: photo_before.dateadded,
        lastupdate: photo_before.lastupdate,
        views: photo_before.views,
        title: photo_before.title,
        description: photo_before.description,
        faves: photo_before.faves,
        seen_at: now
      )

    end

    it "sets a new photo's faves to 0 if the request for faves fails" do
      stub_get_photos
      mock_get_comments_and_tags
      allow(FlickrUpdater).to receive(:fave_count) { nil }
      FlickrUpdater.update_all_photos
      expect(Photo.first.faves).to eq(0)
    end

    it "leaves an existing photo's faves alone if the request for faves fails" do
      stub_get_photos
      mock_get_comments_and_tags
      allow(FlickrUpdater).to receive(:fave_count) { nil }
      photo = create :photo, faves: 6
      FlickrUpdater.update_all_photos
      expect(photo.reload.faves).to eq(6)
    end

    it "stores 0 latitude, longitude and accuracy as nil" do
      stub_get_photos latitude: 0, longitude: 0, accuracy: 0
      stub_get_faves
      mock_get_comments_and_tags
      expect(FlickrUpdater.update_all_photos).to eq([ 1, 1, 1, 1 ])
      expect(Photo.first_and_only).to have_attributes(
        latitude: nil,
        longitude: nil,
        accuracy: nil,
      )
    end

  end

  describe '.update_photo' do
    let(:photo) { create :photo }
    let!(:now) { Time.utc 2014 }

    before do
      allow(Time).to receive(:now) { now }
    end

    it "loads the photo and its person, location, faves, comments and tags from Flickr" do
      stub_get_person
      stub_get_photo
      stub_get_photo_location
      allow(FlickrUpdater).to receive(:fave_count).with(photo.flickrid) { 7 }
      expect(FlickrUpdater).to receive(:update_comments).with photo
      expect(FlickrUpdater).to receive(:update_tags).with photo
      FlickrUpdater.update_photo photo

      expect(photo.person).to have_attributes(
        username: 'new_username',
        pathalias: 'new_pathalias'
      )
      expect(photo).to have_attributes(
        farm: '1',
        server: 'incoming_server',
        secret: 'incoming_secret',
        views: 50,
        title: 'The title',
        description: 'The description',
        datetaken: Time.local(2010), # local because we assume that the photo was taken in SF
        lastupdate: Time.utc(2011, 1, 1, 1),
        seen_at: now,
        latitude: 37.123456,
        longitude: -122.654321,
        accuracy: 16,
        faves: 7,
      )

    end

    it "handles a photo with no location information" do
      stub_get_person
      stub_get_photo
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: photo.flickrid) do
        raise FlickrService::FlickrReturnedAnError, stat: 'fail', code: 2, msg: "whatever"
      end
      allow(FlickrUpdater).to receive(:fave_count).with(photo.flickrid) { 7 }
      allow(FlickrUpdater).to receive(:update_comments).with photo
      allow(FlickrUpdater).to receive(:update_tags).with photo
      FlickrUpdater.update_photo photo

      expect(photo).to have_attributes(
        latitude: nil,
        longitude: nil,
        accuracy: nil
      )

    end

    it "does not attempt to handle other errors returned when requesting location" do
      stub_get_person
      stub_get_photo
      error = FlickrService::FlickrReturnedAnError.new stat: 'fail', code: 1, msg: "whatever"
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: photo.flickrid) { raise error }
      expect { FlickrUpdater.update_photo photo }.to raise_error error
    end

    it "does not attempt to handle other errors when requesting location" do
      stub_get_person
      stub_get_photo
      error = FlickrService::FlickrRequestFailedError
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: photo.flickrid) { raise error }
      expect { FlickrUpdater.update_photo photo }.to raise_error error
    end

    it "moves on if there is an error getting faves" do
      stub_get_person
      stub_get_photo
      stub_get_photo_location
      allow(FlickrUpdater).to receive(:fave_count).with(photo.flickrid) { nil }
      allow(FlickrUpdater).to receive(:update_comments).with photo
      allow(FlickrUpdater).to receive(:update_tags).with photo
      FlickrUpdater.update_photo photo
      expect(photo.faves).to eq(0)
    end

    it "only updates the photo's seen_at and the person if the photo hasn't been updated, for performance" do
      photo.update! lastupdate: Time.utc(2013)
      old_photo_attrs = photo.attributes
      stub_get_person
      stub_get_photo lastupdate: Time.utc(2013)
      expect(FlickrService.instance).not_to receive(:photos_geo_get_location)
      expect(FlickrUpdater).not_to receive(:fave_count)
      expect(FlickrUpdater).not_to receive(:update_comments)
      expect(FlickrUpdater).not_to receive(:update_tags)
      FlickrUpdater.update_photo photo

      expect(photo.person).to have_attributes(
        username: 'new_username',
        pathalias: 'new_pathalias'
      )
      expect(photo).to have_attributes(
        farm: old_photo_attrs['farm'],
        server: old_photo_attrs['server'],
        secret: old_photo_attrs['secret'],
        views: old_photo_attrs['views'],
        title: old_photo_attrs['title'],
        description: old_photo_attrs['description'],
        datetaken: old_photo_attrs['datetaken'],
        lastupdate: old_photo_attrs['lastupdate'],
        seen_at: now,
        latitude: nil,
        longitude: nil,
        accuracy: nil,
        faves: old_photo_attrs['faves']
      )

    end

    it "doesn't request comments if the photo has none, for performance" do
      stub_get_person
      stub_get_photo comments: 0
      stub_get_photo_location
      allow(FlickrUpdater).to receive(:fave_count).with(photo.flickrid) { 7 }
      expect(FlickrUpdater).not_to receive(:update_comments)
      allow(FlickrUpdater).to receive(:update_tags).with photo
      FlickrUpdater.update_photo photo
    end

    it "doesn't request tags if the photo has none, for performance" do
      stub_get_person
      stub_get_photo tags: []
      stub_get_photo_location
      allow(FlickrUpdater).to receive(:fave_count).with(photo.flickrid) { 7 }
      allow(FlickrUpdater).to receive(:update_comments)
      expect(FlickrUpdater).not_to receive(:update_tags)
      FlickrUpdater.update_photo photo
    end

    def stub_get_person
      allow(FlickrService.instance).to receive(:people_get_info).with(user_id: photo.person.flickrid) do
        {
          'person' => [{
            'username' => ['new_username'],
            'photosurl' => ['https://www.flickr.com/photos/new_pathalias/']
          }]
        }
      end
    end

    def stub_get_photo(lastupdate: Time.utc(2011, 1, 1, 1), comments: 1, tags: ['Tag 1'])
      allow(FlickrService.instance).to receive(:photos_get_info).with(photo_id: photo.flickrid) do
        {
          'photo' => [{
            'farm' => '1',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'views' => '50',
            'title' => ['The title'],
            'description' => ['The description'],
            'dates' => [{
              'taken' => Time.utc(2010).strftime("%Y-%m-%d %H-%M-%S"),
              'lastupdate' => lastupdate.to_i.to_s
            }],
            'comments' => ["#{comments}"],
            'tags' => [
              # The response is structured differently if there are no tags than if there are tags
              if tags.any?
                { 'tag' => tags.map { |tag| { 'raw' => tag } } }
              else
                {}
              end
            ]
          }]
        }
      end
    end

    def stub_get_photo_location
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: photo.flickrid) do
        {
          'photo' => [{
            'location' => [{
              'latitude' => '37.123456',
              'longitude' => '-122.654321',
              'accuracy' => '16'
            }]
          }]
        }
      end
    end

  end

  describe '.fave_count' do
    it "returns the number of faves that the photo has" do
      allow(FlickrService.instance).to receive(:photos_get_favorites).with(photo_id: 'photo_flickrid', per_page: 1) do
        {
          'stat' => 'ok',
          'photo' => [{ 'total' => '7' }]
        }
      end
      expect(FlickrUpdater.fave_count('photo_flickrid')).to eq(7)
    end

    it "returns nil if there is a REXML::ParseException" do
      allow(FlickrService.instance).to receive(:photos_get_favorites).with(photo_id: 'photo_flickrid', per_page: 1) do
        raise REXML::ParseException, "Oops!"
      end
      expect(FlickrUpdater.fave_count('photo_flickrid')).to eq(nil)
    end

    it "returns nil if there is a FlickrService::FlickrRequestFailedError" do
      allow(FlickrService.instance).to receive(:photos_get_favorites).with(photo_id: 'photo_flickrid', per_page: 1) do
        raise FlickrService::FlickrRequestFailedError
      end
      expect(FlickrUpdater.fave_count('photo_flickrid')).to eq(nil)
    end

  end

  describe '.update_comments' do
    let(:photo) { create :photo }

    it "loads comments from Flickr" do
      stub_request_to_return_one_comment
      FlickrUpdater.update_comments photo
      photo_has_the_comment_from_the_request
    end

    it "deletes previous comments" do
      create :comment, photo: photo
      stub_request_to_return_one_comment
      FlickrUpdater.update_comments photo
      photo_has_the_comment_from_the_request
    end

    it "does not delete previous comments if the photo currently has no comments" do
      create :comment, photo: photo
      allow(FlickrService.instance).to receive(:photos_comments_get_list) do
        {
          'comments' => [{
          }]
        }
      end
      FlickrUpdater.update_comments photo
      expect(photo.comments.length).to eq(1)
      expect(Comment.count).to eq(1)
    end

    it "leaves previous comments alone if the request for comments fails" do
      create :comment, photo: photo
      allow(FlickrService.instance).to receive(:photos_comments_get_list) do
        raise FlickrService::FlickrRequestFailedError
      end
      FlickrUpdater.update_comments photo
      expect(Comment.count).to eq(1)
    end

    def stub_request_to_return_one_comment
      allow(FlickrService.instance).to receive(:photos_comments_get_list).with(photo_id: photo.flickrid) do
        {
          'comments' => [{
            'comment' => [{
              'author' => 'commenter_flickrid',
              'authorname' => 'commenter_username',
              'content' => 'comment text',
              'datecreate' => '1356998400'
            }]
          }]
        }
      end
    end

    def photo_has_the_comment_from_the_request
      expect(photo.comments.length).to eq(1)
      expect(photo.comments.first).to have_attributes(
        flickrid: 'commenter_flickrid',
        username: 'commenter_username',
        comment_text: 'comment text',
        commented_at: Time.utc(2013)
      )
    end

  end

  describe '.update_tags' do
    let(:photo) { create :photo }

    it "loads tags from Flickr" do
      stub_get_tags Tag.new(raw: 'Tag 1'), Tag.new(raw: 'Tag 2', machine_tag: true)
      FlickrUpdater.update_tags photo
      expect(photo.tags.map { |tag| [tag.raw, tag.machine_tag] }).to match_array([['Tag 1', false], ['Tag 2', true]])
    end

    it "deletes previous tags" do
      create :tag, photo: photo, raw: 'old tag'
      stub_get_tags Tag.new(raw: 'new tag')
      FlickrUpdater.update_tags photo
      expect(photo.tags.map(&:raw)).to eq(['new tag'])
    end

    def stub_get_tags(*tags)
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid) do
        {
          'photo' => [{
            'tags' => [{
              'tag' => tags.map { |tag| { 'raw' => tag.raw, 'machine_tag' => (tag.machine_tag ? 1 : 0).to_s } }
            }]
          }]
        }
      end
    end

    it "deletes previous tags if the photo currently has no tags" do
      create :tag, photo: photo, raw: 'old tag'
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid) do
        {
          'photo' => [{
            'tags' => [{
            }]
          }]
        }
      end
      FlickrUpdater.update_tags photo
      expect(photo.tags).to be_empty
    end

    it "leaves previous tags alone if the request for tags fails due to FlickrService::FlickrRequestFailedError" do
      create :tag, photo: photo, raw: 'old tag'
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid) do
        raise FlickrService::FlickrRequestFailedError
      end
      FlickrUpdater.update_tags photo
      expect(photo.tags.map(&:raw)).to eq(['old tag'])
    end

    it "leaves previous tags alone if the request for tags fails due to REXML::ParseException" do
      create :tag, photo: photo, raw: 'old tag'
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid) do
        raise REXML::ParseException, "Flickr sent bad XML"
      end
      FlickrUpdater.update_tags photo
      expect(photo.tags.map(&:raw)).to eq(['old tag'])
    end

  end

end
