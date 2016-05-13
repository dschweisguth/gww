describe PersonUpdater, type: :updater do
  describe '.update_all' do
    it "updates an existing user's username, realname and pathalias" do
      person = create :person, username: 'old_username', realname: 'old_realname', pathalias: 'old_pathalias'
      allow(FlickrService.instance).to receive(:people_get_info) do
        {
          'person' => [{
            'username' => ['new_username'],
            'realname' => ['new_realname'],
            'photosurl' => ['https://www.flickr.com/photos/new_pathalias/']
          }]
        }
      end
      PersonUpdater.update_all
      person.reload
      expect(person.username).to eq('new_username')
      expect(person.realname).to eq('new_realname')
      expect(person.pathalias).to eq('new_pathalias')
    end

    it "handles an error" do
      person = create :person, username: 'old_username', realname: 'old_realname', pathalias: 'old_pathalias'
      allow(FlickrService.instance).to receive(:people_get_info) do
        raise FlickrService::FlickrRequestFailedError, "Couldn't get info from Flickr"
      end
      PersonUpdater.update_all
      person.reload
      expect(person.username).to eq('old_username')
      expect(person.realname).to eq('old_realname')
      expect(person.pathalias).to eq('old_pathalias')
    end

  end
end
