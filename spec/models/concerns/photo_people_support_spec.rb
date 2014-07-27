describe Photo do
  describe '.for_person_for_map' do
    let(:person) { build :person }
    let(:bounds) { Bounds.new 37.70571, 37.820904, -122.514381, -122.35714 }

    before do
      stub(Person).find(person.id) { person }
    end

    it "returns a post" do
      returns_post 'unfound', Color::Yellow.scaled(0, 0, 0), '?'
    end

    it "configures an unconfirmed post like an unfound" do
      returns_post 'unconfirmed', Color::Yellow.scaled(0, 0, 0), '?'
    end

    it "configures a found differently" do
      returns_post 'found', Color::Blue.scaled(0, 1, 1), '?'
    end

    it "configures a revealed post differently" do
      returns_post 'revealed', Color::Red.scaled(0, 1, 1), '-'
    end

    # noinspection RubyArgCount
    def returns_post(game_status, color, symbol)
      post = build :photo, person_id: person.id, latitude: 37, longitude: -122, game_status: game_status
      stub(Photo).posted_or_guessed_by_and_mapped(person.id, bounds, 2) { [ post ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      Photo.for_person_for_map(person.id, bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: [
          {
            'id' => post.id,
            'latitude' => post.latitude,
            'longitude' => post.longitude,
            'color' => color,
            'symbol' => symbol
          }
        ]
      }
    end

    it "copies an inferred geocode to the stated one" do
      post = build :photo, person_id: person.id, inferred_latitude: 37, inferred_longitude: -122
      stub(Photo).posted_or_guessed_by_and_mapped(person.id, bounds, 2) { [ post ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      Photo.for_person_for_map(person.id, bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: [
          {
            'id' => post.id,
            'latitude' => post.inferred_latitude,
            'longitude' => post.inferred_longitude,
            'color' => Color::Yellow.scaled(0, 0, 0),
            'symbol' => '?'
          }
        ]
      }
    end

    it "returns a guess" do
      photo = build :photo, person_id: 2, latitude: 37, longitude: -122
      stub(Photo).posted_or_guessed_by_and_mapped(person.id, bounds, 2) { [ photo ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      Photo.for_person_for_map(person.id, bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => Color::Green.scaled(0, 1, 1),
            'symbol' => '!'
          }
        ]
      }
    end

    it "returns no more than a maximum number of photos" do
      post = build :photo, person_id: person.id, latitude: 37, longitude: -122
      oldest_photo = build :photo, dateadded: 1.day.ago
      stub(Photo).posted_or_guessed_by_and_mapped(person.id, bounds, 2) { [ post, oldest_photo ] }
      stub(Photo).oldest { oldest_photo }
      Photo.for_person_for_map(person.id, bounds, 1).should == {
        partial: true,
        bounds: bounds,
        photos: [
          {
            'id' => post.id,
            'latitude' => post.latitude,
            'longitude' => post.longitude,
            'color' => Color::Yellow.scaled(0, 0, 0),
            'symbol' => '?'
          }
        ]
      }
    end

    it "handles no photos" do
      stub(Photo).posted_or_guessed_by_and_mapped(person.id, bounds, 2) { [] }
      stub(Photo).oldest { nil }
      Photo.for_person_for_map(person.id, bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: []
      }
    end

  end

end
