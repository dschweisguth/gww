describe PhotoPhotosSupport do

  describe '#all_for_map' do
    let(:bounds) { Bounds.new 37.70571, 37.820904, -122.514381, -122.35714 }

    it "returns an unfound photo" do
      photo = build :photo, latitude: 37, longitude: -122
      stub(Photo).mapped(bounds, 2) { [ photo ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      Photo.all_for_map(bounds, 1).should == {
        partial: false,
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
      }
    end

    it "handles no photos" do
      stub(Photo).mapped(bounds, 2) { [] }
      stub(Photo).oldest { nil }
      Photo.all_for_map(bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: []
      }
    end

    it "echos non-default bounds" do
      bounds = Bounds.new 1, 3, 2, 4
      stub(Photo).mapped(bounds, 2) { [] }
      stub(Photo).oldest { nil }
      Photo.all_for_map(bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: []
      }
    end

    # TODO Dave this is tested elsewhere
    it "copies an inferred geocode to the stated one" do
      photo = build :photo, inferred_latitude: 37, inferred_longitude: -122
      stub(Photo).mapped(bounds, 2) { [ photo ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      Photo.all_for_map(bounds, 1).should == {
        partial: false,
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
      }
    end

    it "returns no more than a maximum number of photos" do
      photo = build :photo, latitude: 37, longitude: -122
      oldest_photo = build :photo, dateadded: 1.day.ago
      stub(Photo).mapped(bounds, 2) { [ photo, oldest_photo ] }
      stub(Photo).oldest { oldest_photo }
      Photo.all_for_map(bounds, 1).should == {
        partial: true,
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
      }
    end

    it "moves a younger photo so that it doesn't completely overlap an older photo with an identical location" do
      photo1 = build :photo, latitude: 37, longitude: -122, dateadded: 1.day.ago
      photo2 = build :photo, latitude: 37, longitude: -122
      stub(Photo).mapped(bounds, 3) { [ photo2, photo1 ] }
      stub(Photo).oldest { photo1 }
      photos = Photo.all_for_map(bounds, 2)[:photos]
      photos[0]['latitude'].should be_within(0.000001).of 36.999991
      photos[0]['longitude'].should be_within(0.000001).of -122.000037
      photos[1]['latitude'].should == 37
      photos[1]['longitude'].should == -122
    end

  end

end
