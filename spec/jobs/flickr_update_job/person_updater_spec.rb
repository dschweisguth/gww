describe FlickrUpdateJob::PersonUpdater, type: :job do
  describe '.update_all' do
    let!(:person) { create :person, username: 'old_username', realname: 'old_realname', pathalias: 'old_pathalias' }

    it "updates an existing user's username, realname and pathalias" do
      allow(FlickrService.instance).to receive(:people_get_info) do
        {
          'person' => [{
            'username' => ['new_username'],
            'realname' => ['new_realname'],
            'photosurl' => ['https://www.flickr.com/photos/new_pathalias/']
          }]
        }
      end
      update_all_and_expect_person_to_have username: 'new_username', realname: 'new_realname', pathalias: 'new_pathalias'
    end

    it "handles an error" do
      allow(FlickrService.instance).to receive(:people_get_info) do
        raise FlickrService::FlickrRequestFailedError, "Couldn't get info from Flickr"
      end
      update_all_and_expect_person_to_have username: 'old_username', realname: 'old_realname', pathalias: 'old_pathalias'
    end

    it "handles a missing realname" do
      allow(FlickrService.instance).to receive(:people_get_info) do
        {
          'person' => [{
            'username' => ['new_username'],
            'photosurl' => ['https://www.flickr.com/photos/new_pathalias/']
          }]
        }
      end
      # if a user hides their real name, updating should forget it
      update_all_and_expect_person_to_have username: 'new_username', realname: nil, pathalias: 'new_pathalias'
    end

    it "handles an empty realname" do
      allow(FlickrService.instance).to receive(:people_get_info) do
        {
          'person' => [{
            'username' => ['new_username'],
            'realname' => [{}],
            'photosurl' => ['https://www.flickr.com/photos/new_pathalias/']
          }]
        }
      end
      # if a user hides their real name, updating should forget it
      update_all_and_expect_person_to_have username: 'new_username', realname: nil, pathalias: 'new_pathalias'
    end

    def update_all_and_expect_person_to_have(attrs)
      FlickrUpdateJob::PersonUpdater.update_all
      person.reload
      relevant_attrs = person.attributes.symbolize_keys.slice *attrs.keys
      expect(relevant_attrs).to eq(attrs)
    end

  end
end
