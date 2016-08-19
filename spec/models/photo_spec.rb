describe Photo do
  describe '#flickrid' do
    it { does validate_presence_of :flickrid }
    it { does have_readonly_attribute :flickrid }
  end

  describe '#dateadded' do
    it { does validate_presence_of :dateadded }
  end

  describe '#latitude' do
    it { does validate_numericality_of(:latitude).allow_nil }
  end

  describe '#longitude' do
    it { does validate_numericality_of(:longitude).allow_nil }
  end

  describe '#accuracy' do
    it { does validate_numericality_of(:accuracy).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe '#latitude, #longitude, #accuracy' do
    it "is valid if all are absent" do
      expect(build(:photo, latitude: nil, longitude: nil, accuracy: nil)).to be_valid
    end

    it "is valid if all are present" do
      expect(build(:photo, latitude: 0, longitude: 0, accuracy: 0)).to be_valid
    end

    %i(latitude longitude accuracy).each do |attr|
      it "is invalid if only #{attr} is absent" do
        attrs = { latitude: 0, longitude: 0, accuracy: 0 }
        attrs[attr] = nil
        expect(build(:photo, attrs)).not_to be_valid
      end
    end

    %i(latitude longitude accuracy).each do |attr|
      it "is invalid if only #{attr} is present" do
        attrs = { latitude: nil, longitude: nil, accuracy: nil }
        attrs[attr] = 0
        expect(build(:photo, attrs)).not_to be_valid
      end
    end

  end

  describe '#lastupdate' do
    it { does validate_presence_of :lastupdate }
  end

  describe '#seen_at' do
    it { does validate_presence_of :seen_at }
  end

  describe '#game_status' do
    it { does validate_presence_of :game_status }
    it { does validate_inclusion_of(:game_status).in_array %w(unfound unconfirmed found revealed) }
  end

  describe '#views' do
    it { does validate_numericality_of(:views).is_greater_than_or_equal_to(0) }
  end

  describe '#faves' do
    it { does validate_numericality_of(:faves).is_greater_than_or_equal_to(0) }
  end

  describe '#other_user_comments' do
    it { does validate_numericality_of(:other_user_comments).is_greater_than_or_equal_to(0) }
  end

  describe '#member_comments' do
    it { does validate_numericality_of(:member_comments).is_greater_than_or_equal_to(0) }
  end

  describe '#member_questions' do
    it { does validate_numericality_of(:member_questions).is_greater_than_or_equal_to(0) }
  end

  describe '#inferred_latitude' do
    it { does validate_numericality_of(:inferred_latitude).allow_nil }
  end

  describe '#inferred_longitude' do
    it { does validate_numericality_of(:inferred_longitude).allow_nil }
  end

  describe '#inferred_latitude, #inferred_longitude' do
    it "is valid if both are absent" do
      expect(build(:photo, inferred_latitude: nil, inferred_longitude: nil)).to be_valid
    end

    it "is valid if both are present" do
      expect(build(:photo, inferred_latitude: 0, inferred_longitude: 0)).to be_valid
    end

    %i(inferred_latitude inferred_longitude).each do |attr|
      it "is invalid if only #{attr} is absent" do
        attrs = { inferred_latitude: 0, inferred_longitude: 0 }
        attrs[attr] = nil
        expect(build(:photo, attrs)).not_to be_valid
      end
    end

  end

  describe '#destroy' do
    let(:photo) { create :photo }

    it "destroys the photo and its person" do
      photo.destroy
      expect(Photo.any?).to be_falsy
      expect(Person.any?).to be_falsy
    end

    it "leaves the person alone if they have another photo" do
      person = photo.person
      create :photo, person: person
      photo.destroy
      expect(Photo.exists?(photo.id)).to be_falsy
      expect(Person.exists?(person.id)).to be_truthy
    end

    it "leaves the person alone if they have a guess" do
      person = photo.person
      create :guess, person: person
      photo.destroy
      expect(Photo.exists?(photo.id)).to be_falsy
      expect(Person.exists?(person.id)).to be_truthy
    end

    it "destroys the photo's tags" do
      create :tag, photo: photo
      photo.destroy
      expect(Tag.any?).to be_falsy
    end

    it "destroys the photo's comments" do
      create :comment, photo: photo
      photo.destroy
      expect(Comment.any?).to be_falsy
    end

    it "destroys the photo's revelation" do
      create :revelation, photo: photo
      photo.destroy
      expect(Revelation.any?).to be_falsy
    end

    it "destroys the photo's guesses" do
      create :guess, photo: photo
      photo.destroy
      expect(Guess.any?).to be_falsy
    end

  end

  describe '.find_with_associations' do
    let(:photo_in) { create :photos_photo }

    it "returns a revealed photo with all of its associated objects" do
      revelation = create :revelation, photo: photo_in
      photo_out = PhotosPhoto.find_with_associations photo_in.id
      expect(photo_out.person).to eq(photo_in.person)
      expect(photo_out.revelation).to eq(revelation)
    end

    it "returns a guessed photo with all of its associated objects" do
      guess = create :guess, photo: photo_in
      photo_out = PhotosPhoto.find_with_associations photo_in.id
      expect(photo_out.person).to eq(photo_in.person)
      expect(photo_out.guesses).to eq([guess])
      expect(photo_out.guesses[0].person).to eq(guess.person)
    end

  end

  describe '#time_elapsed' do
    it "returns the age with a precision of seconds in English" do
      photo = Photo.new dateadded: Time.utc(2000)
      allow(Time).to receive(:now) { Time.utc(2001, 2, 2, 1, 1, 1) }
      expect(photo.time_elapsed).to eq('1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second')
    end
  end

  describe '#mapped' do
    it "returns false if the photo is not mapped" do
      expect(build(:photo).mapped?).to eq(false)
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      expect(build(:photo, latitude: 37, longitude: -122, accuracy: 12).mapped?).to eq(true)
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      expect(build(:photo, latitude: 37, longitude: -122, accuracy: 11).mapped?).to eq(false)
    end

    it "returns false even if the photo is auto-mapped" do
      expect(build(:photo, inferred_latitude: 37, inferred_longitude: -122).mapped?).to eq(false)
    end

  end

  describe '#mapped_or_automapped' do
    it "returns false if the photo is not mapped" do
      expect(build(:photo).mapped_or_automapped?).to eq(false)
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      expect(build(:photo, latitude: 37, longitude: -122, accuracy: 12).mapped_or_automapped?).to eq(true)
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      expect(build(:photo, latitude: 37, longitude: -122, accuracy: 11).mapped_or_automapped?).to eq(false)
    end

    it "returns true if the photo is auto-mapped" do
      expect(build(:photo, inferred_latitude: 37, inferred_longitude: -122).mapped_or_automapped?).to eq(true)
    end

  end

end
