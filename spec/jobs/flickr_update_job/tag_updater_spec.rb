describe FlickrUpdateJob::TagUpdater do
  describe '.update' do
    let(:photo) { create :flickr_update_photo }

    it "loads tags from Flickr" do
      stub_get_tags Tag.new(raw: 'Tag 1'), Tag.new(raw: 'Tag 2', machine_tag: true)
      described_class.update photo
      expect(photo.tags.map { |tag| [tag.raw, tag.machine_tag] }).to contain_exactly(['Tag 1', false], ['Tag 2', true])
    end

    it "deletes previous tags" do
      create :tag, photo: photo, raw: 'old tag'
      stub_get_tags Tag.new(raw: 'new tag')
      described_class.update photo
      expect(photo.tags.map(&:raw)).to eq(['new tag'])
    end

    def stub_get_tags(*tags)
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid).and_return({
        'photo' => [{
          'tags' => [{
            'tag' => tags.map { |tag| { 'raw' => tag.raw, 'machine_tag' => (tag.machine_tag ? 1 : 0).to_s } }
          }]
        }]
      })
    end

    it "deletes previous tags if the photo currently has no tags" do
      create :tag, photo: photo, raw: 'old tag'
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid).and_return({
        'photo' => [{
          'tags' => [{}]
        }]
      })
      described_class.update photo
      expect(photo.tags).to be_empty
    end

    it "leaves previous tags alone if the request for tags fails due to FlickrService::FlickrRequestFailedError" do
      create :tag, photo: photo, raw: 'old tag'
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid).
        and_raise(FlickrService::FlickrRequestFailedError)
      described_class.update photo
      expect(photo.tags.map(&:raw)).to eq(['old tag'])
    end

    it "leaves previous tags alone if the request for tags fails due to REXML::ParseException" do
      create :tag, photo: photo, raw: 'old tag'
      allow(FlickrService.instance).to receive(:tags_get_list_photo).with(photo_id: photo.flickrid).
        and_raise(REXML::ParseException, "Flickr sent bad XML")
      described_class.update photo
      expect(photo.tags.map(&:raw)).to eq(['old tag'])
    end
  end
end
