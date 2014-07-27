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

  end

end
