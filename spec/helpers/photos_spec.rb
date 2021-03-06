describe Photos do
  describe '#url_for_flickr_photo' do
    it "returns the URL to the given photo's Flickr page" do
      photo = build_stubbed :photo
      expect(url_for_flickr_photo(photo)).to eq(
        "https://www.flickr.com/photos/#{photo.person.pathalias}/#{photo.flickrid}/"
      )
    end

    it "falls back on the poster's flickrid if they have no pathalias" do
      photo = build_stubbed :photo
      photo.person.pathalias = nil
      expect(url_for_flickr_photo(photo)).to eq(
        "https://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/"
      )
    end

  end

  describe '#url_for_flickr_photo_in_pool' do
    it "returns the URL to the given photo's Flickr page, in the GWSF pool" do
      photo = build_stubbed :photo
      expect(url_for_flickr_photo_in_pool(photo)).to eq(
        "https://www.flickr.com/photos/#{photo.person.pathalias}/#{photo.flickrid}/in/pool-guesswheresf/"
      )
    end
  end

  describe '#url_for_flickr_image' do
    it "returns the URL to the given photo" do
      photo = build_stubbed :photo
      expect(url_for_flickr_image(photo)).to eq(
        "https://farm#{photo.farm}.staticflickr.com/#{photo.server}/#{photo.flickrid}_#{photo.secret}.jpg"
      )
    end

    it "handles missing farm" do
      photo = build_stubbed :photo, farm: ''
      expect(url_for_flickr_image(photo)).to eq(
        "https://staticflickr.com/#{photo.server}/#{photo.flickrid}_#{photo.secret}.jpg"
      )
    end

    it "provides the requested size" do
      photo = build_stubbed :photo
      expect(url_for_flickr_image(photo, 't')).to eq(
        "https://farm#{photo.farm}.staticflickr.com/#{photo.server}/#{photo.flickrid}_#{photo.secret}_t.jpg"
      )
    end

  end

end
