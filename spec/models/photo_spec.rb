describe Photo do
  describe '#flickrid' do
    it { is_expected.to validate_presence_of :flickrid }
    it { is_expected.to have_readonly_attribute :flickrid }
  end

  describe '#dateadded' do
    it { is_expected.to validate_presence_of :dateadded }
  end

  describe '#latitude' do
    it { is_expected.to validate_numericality_of :latitude }
  end

  describe '#longitude' do
    it { is_expected.to validate_numericality_of :longitude }
  end

  describe '#accuracy' do
    it { is_expected.to validate_numericality_of :accuracy }
    it { is_expected.to validate_non_negative_integer :accuracy }
  end

  describe '#lastupdate' do
    it { is_expected.to validate_presence_of :lastupdate }
  end

  describe '#seen_at' do
    it { is_expected.to validate_presence_of :seen_at }
  end

  describe '#game_status' do
    it { is_expected.to validate_presence_of :game_status }
    it { is_expected.to validate_inclusion_of(:game_status).in_array %w(unfound unconfirmed found revealed) }
  end

  describe '#views' do
    it { is_expected.to validate_presence_of :views }
    it { is_expected.to validate_non_negative_integer :views }
  end

  describe '#faves' do
    it { is_expected.to validate_presence_of :faves }
    it { is_expected.to validate_non_negative_integer :faves }
  end

  describe '#other_user_comments' do
    it { is_expected.to validate_presence_of :other_user_comments }
    it { is_expected.to validate_non_negative_integer :other_user_comments }
  end

  describe '#member_comments' do
    it { is_expected.to validate_presence_of :member_comments }
    it { is_expected.to validate_non_negative_integer :member_comments }
  end

  describe '#member_questions' do
    it { is_expected.to validate_presence_of :member_questions }
    it { is_expected.to validate_non_negative_integer :member_questions }
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

  describe '#time_elapsed' do
    it 'returns the age with a precision of seconds in English' do
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
