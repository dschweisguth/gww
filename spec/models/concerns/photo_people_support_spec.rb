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

  describe '.posted_or_guessed_by_and_mapped' do
    let(:bounds) { Bounds.new 36, 38, -123, -121 }

    it "returns photos posted by the person" do
      returns_post latitude: 37, longitude: -122, accuracy: 12
    end

    it "ignores other people's posts" do
      create :photo, latitude: 37, longitude: -122, accuracy: 12
      other_person = create :person
      Photo.posted_or_guessed_by_and_mapped(other_person.id, bounds, 1).should == []
    end

    it "returns photos guessed by the person" do
      photo = create :photo, latitude: 37, longitude: -122, accuracy: 12
      guess = create :guess, photo: photo
      Photo.posted_or_guessed_by_and_mapped(guess.person.id, bounds, 1).should == [ photo ]
    end

    it "ignores other people's guesses" do
      photo = create :photo, latitude: 37, longitude: -122, accuracy: 12
      create :guess, photo: photo
      other_person = create :person
      Photo.posted_or_guessed_by_and_mapped(other_person.id, bounds, 1).should == []
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
      photo = create :photo, latitude: 37, longitude: -122, accuracy: 12
      create :photo, latitude: 37, longitude: -122, dateadded: 1.day.ago, accuracy: 12
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1).should == [ photo ]
    end

    def returns_post(attributes)
      photo = create :photo, attributes
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1).should == [ photo ]
    end

    def ignores_post(attributes)
      photo = create :photo, attributes
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1).should == []
    end

  end

  describe '#ymd_elapsed' do
    it 'returns the age with a precision of days in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      stub(Time).now { Time.utc(2001, 2, 2, 1, 1, 1) }
      photo.ymd_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day'
    end
  end

  describe '#star_for_comments' do
    expected = { 0 => nil, 20 => :silver, 30 => :gold }
    expected.keys.sort.each do |other_user_comments|
      it "returns a #{expected[other_user_comments]} star for a photo with #{other_user_comments} comments" do
        photo = Photo.new other_user_comments: other_user_comments
        photo.star_for_comments.should == expected[other_user_comments]
      end
    end
  end

  describe '#star_for_views' do
    expected = { 0 => nil, 300 => :bronze, 1000 => :silver, 3000 => :gold }
    expected.keys.sort.each do |views|
      it "returns a #{expected[views]} star for a photo with #{views} views" do
        photo = Photo.new views: views
        photo.star_for_views.should == expected[views]
      end
    end
  end

  describe '#star_for_faves' do
    expected = { 0 => nil, 10 => :bronze, 30 => :silver, 100 => :gold }
    expected.keys.sort.each do |faves|
      it "returns a #{expected[faves]} star for a photo with #{faves} faves" do
        photo = Photo.new faves: faves
        photo.star_for_faves.should == expected[faves]
      end
    end
  end

  describe '#has_obsolete_tags?' do
    %w(found revealed).each do |game_status|
      it "returns true if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_truthy
      end
    end

    it "is case-insensitive" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'UNFOUNDINSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    %w(unfound unconfirmed).each do |game_status|
      it "returns false if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_falsy
      end
    end

    it "returns false if a found photo is tagged something else" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unseeninSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a found photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns true if a found photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

  end

end
