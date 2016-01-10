describe MultiPhotoMapSupport do
  describe '#as_map_json' do
    it "returns JSON-ready data including the given indication of whether or not the list is partial, bounds and photos" do
      photo = build :photo, latitude: 37, longitude: -122, color: Color::Yellow.scaled(0, 0, 0), symbol: '?'
      bounds = Bounds.new 1, 3, 2, 4
      partial = false
      expect(Photo.as_map_json(partial, bounds, [photo])).to eq(
        partial: partial,
        bounds: bounds,
        photos: [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => Color::Yellow.scaled(0, 0, 0),
            'symbol' => '?'
          }
        ]
      )
    end

    # See below for the details of how photos are moved
    it "moves younger photos so that they don't completely overlap older photos with identical locations" do
      photos = build_list :photo, 2, latitude: 37, longitude: -122, color: Color::Yellow.scaled(0, 0, 0), symbol: '?'
      bounds = Bounds.new 1, 3, 2, 4
      partial = false
      photo_json = Photo.as_map_json(partial, bounds, photos)[:photos]
      expect(photo_json[0]['latitude']).not_to eq(photo_json[1]['latitude'])
      expect(photo_json[0]['longitude']).not_to eq(photo_json[1]['longitude'])
    end

  end

  describe '#perturb_identical_locations' do
    it "moves younger photos so that they don't completely overlap older photos with identical locations" do
      photos = build_list :photo, 3, latitude: 37, longitude: -122
      Photo.perturb_identical_locations photos
      # Increasingly younger photos are moved farther along the involute of a circle
      expect(photos[0].latitude).to be_within(0.000001).of 36.999951
      expect(photos[0].longitude).to be_within(0.000001).of -122.000003
      expect(photos[1].latitude).to be_within(0.000001).of 36.999991
      expect(photos[1].longitude).to be_within(0.000001).of -122.000037
      expect(photos[2].latitude).to eq(37)
      expect(photos[2].longitude).to eq(-122)
    end
  end

end
