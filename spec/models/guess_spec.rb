describe Guess do
  describe '#person_id' do
    let(:existing) { create :guess }

    it "is unique for a given photo and comment text" do
      expect(build(:guess, photo: existing.photo, person: existing.person, comment_text: existing.comment_text)).not_to be_valid
    end

    it "need not be unique if the photo is different" do
      expect(build(:guess, person: existing.person, comment_text: existing.comment_text)).to be_valid
    end

    it "need not be unique if the comment_text is different" do
      expect(build(:guess, photo: existing.photo, person: existing.person)).to be_valid
    end

  end

  describe '#comment_text' do
    it { does validate_presence_of :comment_text }

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      create :guess, comment_text: non_ascii_text
      expect(Guess.all[0].comment_text).to eq(non_ascii_text)
    end

  end

  describe '#commented_at' do
    it { does validate_presence_of :commented_at }
  end

  describe '#added_at' do
    it { does validate_presence_of :added_at }
  end

  describe '#destroy' do
    let(:guess) { create :guess }
    let(:person) { guess.person }

    it "destroys the guess and its person" do
      guess.destroy
      expect(Guess.any?).to be_falsy
      expect(Person.exists?(person.id)).to be_falsy
      expect(Photo.exists?(guess.photo.id)).to be_truthy
    end

    it "leaves the person alone if they have another guess" do
      create :guess, person: person
      guess.destroy
      expect(Guess.exists?(guess.id)).to be_falsy
      expect(Person.exists?(person.id)).to be_truthy
      expect(Photo.exists?(guess.photo.id)).to be_truthy
    end

    it "leaves the person alone if they have a photo" do
      create :photo, person: person
      guess.destroy
      expect(Guess.any?).to be_falsy
      expect(Person.exists?(person.id)).to be_truthy
      expect(Photo.exists?(guess.photo.id)).to be_truthy
    end

  end

  describe '.destroy_all_by_photo_id' do
    let(:guess) { create :guess }

    it 'destroys all guesses of the photo with the given id' do
      Guess.destroy_all_by_photo_id guess.photo.id
      expect(Guess.any?).to be_falsy
    end

    it "ignores other photos' guesses" do
      other_guess = create :guess
      Guess.destroy_all_by_photo_id guess.photo.id
      expect(Guess.all).to eq([ other_guess ])
    end

  end

  describe '.longest' do
    it 'lists guesses sorted by time between post and guess, descending' do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      expect(Guess.longest).to eq([ guess2, guess1 ])
    end

    it 'ignores a guess made before it was posted' do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, commented_at: Time.utc(2010)
      expect(Guess.longest).to eq([])
    end

  end

  describe '.shortest' do
    it 'lists guesses sorted by time between post and guess, ascending' do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2002)
      photo2 = create :photo, dateadded: Time.utc(2003)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      expect(Guess.shortest).to eq([ guess2, guess1 ])
    end

    it 'ignores a guess made before it was posted' do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, commented_at: Time.utc(2010)
      expect(Guess.shortest).to eq([])
    end

  end

  describe '#time_elapsed' do
    it 'returns the duration in seconds from post to guess in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      guess = Guess.new photo: photo, commented_at: Time.utc(2001, 2, 2, 1, 1, 1)
      expect(guess.time_elapsed).to eq('1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second')
    end
  end

  describe '#ymd_elapsed' do
    it 'returns the duration in days from post to guess in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      guess = Guess.new photo: photo, commented_at: Time.utc(2001, 2, 2, 1, 1, 1)
      expect(guess.ymd_elapsed).to eq('1&nbsp;year, 1&nbsp;month, 1&nbsp;day')
    end
  end

end
