describe FlickrUpdateJob::FaveCounter do
  describe '.count' do
    it "returns the number of faves that the photo has" do
      allow(FlickrService.instance).to receive(:photos_get_favorites).with(photo_id: 'photo_flickrid', per_page: 1).and_return({
        'stat' => 'ok',
        'photo' => [{ 'total' => '7' }]
      })
      expect(described_class.count('photo_flickrid')).to eq(7)
    end

    it "returns nil if there is a REXML::ParseException" do
      allow(FlickrService.instance).to receive(:photos_get_favorites).with(photo_id: 'photo_flickrid', per_page: 1).
        and_raise(REXML::ParseException, "Oops!")
      expect(described_class.count('photo_flickrid')).to be_nil
    end

    it "returns nil if there is a FlickrService::FlickrRequestFailedError" do
      allow(FlickrService.instance).to receive(:photos_get_favorites).with(photo_id: 'photo_flickrid', per_page: 1).
        and_raise(FlickrService::FlickrRequestFailedError)
      expect(described_class.count('photo_flickrid')).to be_nil
    end
  end
end
