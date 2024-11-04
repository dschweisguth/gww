describe FlickrUpdateJob::LocationGetter do
  let(:flickrid) { "flickrid" }

  describe '#get' do
    it "gets a photo's location" do
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: flickrid).and_return({
        'photo' => [{
          'location' => [{
            'latitude' => '37.123456',
            'longitude' => '-122.654321',
            'accuracy' => '16'
          }]
        }]
      })
      expect(described_class.get(flickrid)).to eq([37.123456, -122.654321, 16])
    end

    it "returns nils when the photo has no location information" do
      error = FlickrService::FlickrReturnedAnError.new stat: 'fail', code: 2, msg: "whatever"
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: flickrid).and_raise(error)
      expect(described_class.get(flickrid)).to eq([nil, nil, nil])
    end

    it "does not attempt to handle other errors returned by Flickr" do
      error = FlickrService::FlickrReturnedAnError.new stat: 'fail', code: 1, msg: "whatever"
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: flickrid).and_raise(error)
      expect { described_class.get flickrid }.to raise_error error
    end

    it "does not attempt to handle other errors that occur when requesting location" do
      error = FlickrService::FlickrRequestFailedError
      allow(FlickrService.instance).to receive(:photos_geo_get_location).with(photo_id: flickrid).and_raise(error)
      expect { described_class.get flickrid }.to raise_error error
    end
  end
end
