describe PeoplePhoto do
  describe '.for_person_for_map' do
    let(:person) { build :people_person }
    let(:bounds) { Bounds.new 37.70571, 37.820904, -122.514381, -122.35714 }

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

    def returns_post(game_status, color, symbol)
      post = build :people_photo, person_id: person.id, latitude: 37, longitude: -122, game_status: game_status
      allow(PeoplePhoto).to receive(:posted_or_guessed_by_and_mapped).with(person.id, bounds, 2) { [post] }
      allow(PeoplePhoto).to receive(:oldest) { build :people_photo, dateadded: 1.day.ago }
      expect(PeoplePhoto.for_person_for_map(person.id, bounds, 1)).to eq(
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
      )
    end

    it "copies an inferred geocode to the stated one" do
      post = build :people_photo, person_id: person.id, inferred_latitude: 37, inferred_longitude: -122
      allow(PeoplePhoto).to receive(:posted_or_guessed_by_and_mapped).with(person.id, bounds, 2) { [post] }
      allow(PeoplePhoto).to receive(:oldest) { build :people_photo, dateadded: 1.day.ago }
      expect(PeoplePhoto.for_person_for_map(person.id, bounds, 1)).to eq(
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
      )
    end

    it "returns a guess" do
      photo = build :people_photo, person_id: 2, latitude: 37, longitude: -122
      allow(PeoplePhoto).to receive(:posted_or_guessed_by_and_mapped).with(person.id, bounds, 2) { [photo] }
      allow(PeoplePhoto).to receive(:oldest) { build :people_photo, dateadded: 1.day.ago }
      expect(PeoplePhoto.for_person_for_map(person.id, bounds, 1)).to eq(
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
      )
    end

    it "returns no more than a maximum number of photos" do
      post = build :people_photo, person_id: person.id, latitude: 37, longitude: -122
      oldest_photo = build :people_photo, dateadded: 1.day.ago
      allow(PeoplePhoto).to receive(:posted_or_guessed_by_and_mapped).with(person.id, bounds, 2) { [post, oldest_photo] }
      allow(PeoplePhoto).to receive(:oldest) { oldest_photo }
      expect(PeoplePhoto.for_person_for_map(person.id, bounds, 1)).to eq(
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
      )
    end

    it "handles no photos" do
      allow(PeoplePhoto).to receive(:posted_or_guessed_by_and_mapped).with(person.id, bounds, 2).and_return([])
      allow(PeoplePhoto).to receive(:oldest).and_return(nil)
      expect(PeoplePhoto.for_person_for_map(person.id, bounds, 1)).to eq(
        partial: false,
        bounds: bounds,
        photos: []
      )
    end

  end

  describe '.posted_or_guessed_by_and_mapped' do
    let(:bounds) { Bounds.new 36, 38, -123, -121 }

    it "returns photos posted by the person" do
      returns_post latitude: 37, longitude: -122, accuracy: 12
    end

    it "ignores other people's posts" do
      create :people_photo, latitude: 37, longitude: -122, accuracy: 12
      other_person = create :people_person
      expect(PeoplePhoto.posted_or_guessed_by_and_mapped(other_person.id, bounds, 1)).to eq([])
    end

    it "returns photos guessed by the person" do
      photo = create :people_photo, latitude: 37, longitude: -122, accuracy: 12
      guess = create :people_guess, photo: photo
      expect(PeoplePhoto.posted_or_guessed_by_and_mapped(guess.person.id, bounds, 1)).to eq([photo])
    end

    it "ignores other people's guesses" do
      photo = create :people_photo, latitude: 37, longitude: -122, accuracy: 12
      create :people_guess, photo: photo
      other_person = create :people_person
      expect(PeoplePhoto.posted_or_guessed_by_and_mapped(other_person.id, bounds, 1)).to eq([])
    end

    it "returns auto-mapped photos" do
      returns_post inferred_latitude: 37, inferred_longitude: -122
    end

    it "ignores unmapped photos" do
      ignores_post({})
    end

    it "ignores mapped photos with accuracy < 12" do
      ignores_post latitude: 37, longitude: -122, accuracy: 11
    end

    it "ignores mapped photos south of the minimum latitude" do
      ignores_post latitude: 35, longitude: -122, accuracy: 12
    end

    it "ignores mapped photos north of the maximum latitude" do
      ignores_post latitude: 39, longitude: -122, accuracy: 12
    end

    it "ignores mapped photos west of the minimum longitude" do
      ignores_post latitude: 37, longitude: -124, accuracy: 12
    end

    it "ignores mapped photos east of the maximum longitude" do
      ignores_post latitude: 37, longitude: -120, accuracy: 12
    end

    it "ignores auto-mapped photos south of the minimum latitude" do
      ignores_post inferred_latitude: 35, inferred_longitude: -122
    end

    it "ignores auto-mapped photos north of the maximum latitude" do
      ignores_post inferred_latitude: 39, inferred_longitude: -122
    end

    it "ignores auto-mapped photos west of the minimum longitude" do
      ignores_post inferred_latitude: 37, inferred_longitude: -124
    end

    it "ignores auto-mapped photos east of the maximum longitude" do
      ignores_post inferred_latitude: 37, inferred_longitude: -120
    end

    it "returns only the youngest n photos" do
      photo = create :people_photo, latitude: 37, longitude: -122, accuracy: 12
      create :people_photo, latitude: 37, longitude: -122, dateadded: 1.day.ago, accuracy: 12
      expect(PeoplePhoto.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1)).to eq([photo])
    end

    def returns_post(attributes)
      photo = create :people_photo, attributes
      expect(PeoplePhoto.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1)).to eq([photo])
    end

    def ignores_post(attributes)
      photo = create :people_photo, attributes
      expect(PeoplePhoto.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1)).to eq([])
    end

  end

end
