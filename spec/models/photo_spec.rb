describe Photo do
  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#dateadded' do
    it { should validate_presence_of :dateadded }
  end

  describe '#latitude' do
    it { should validate_numericality_of :latitude }
  end

  describe '#longitude' do
    it { should validate_numericality_of :longitude }
  end

  describe '#accuracy' do
    it { should validate_numericality_of :accuracy }
    it { should validate_non_negative_integer :accuracy }
  end

  describe '#lastupdate' do
    it { should validate_presence_of :lastupdate }
  end

  describe '#seen_at' do
    it { should validate_presence_of :seen_at }
  end

  describe '#game_status' do
    it { should validate_presence_of :game_status }
    it { should ensure_inclusion_of(:game_status).in_array %w(unfound unconfirmed found revealed) }
  end

  describe '#views' do
    it { should validate_presence_of :views }
    it { should validate_non_negative_integer :views }
  end

  describe '#faves' do
    it { should validate_presence_of :faves }
    it { should validate_non_negative_integer :faves }
  end

  describe '#other_user_comments' do
    it { should validate_presence_of :other_user_comments }
    it { should validate_non_negative_integer :other_user_comments }
  end

  describe '#member_comments' do
    it { should validate_presence_of :member_comments }
    it { should validate_non_negative_integer :member_comments }
  end

  describe '#member_questions' do
    it { should validate_presence_of :member_questions }
    it { should validate_non_negative_integer :member_questions }
  end

  describe '#destroy' do
    let(:photo) { create :photo }

    it "destroys the photo and its person" do
      photo.destroy
      Photo.any?.should be_falsy
      Person.any?.should be_falsy
    end

    it "leaves the person alone if they have another photo" do
      person = photo.person
      create :photo, person: person
      photo.destroy
      Photo.exists?(photo.id).should be_falsy
      Person.exists?(person.id).should be_truthy
    end

    it "leaves the person alone if they have a guess" do
      person = photo.person
      create :guess, person: person
      photo.destroy
      Photo.exists?(photo.id).should be_falsy
      Person.exists?(person.id).should be_truthy
    end

    it "destroys the photo's tags" do
      create :tag, photo: photo
      photo.destroy
      Tag.any?.should be_falsy
    end

    it "destroys the photo's comments" do
      create :comment, photo: photo
      photo.destroy
      Comment.any?.should be_falsy
    end

    it "destroys the photo's revelation" do
      create :revelation, photo: photo
      photo.destroy
      Revelation.any?.should be_falsy
    end

    it "destroys the photo's guesses" do
      create :guess, photo: photo
      photo.destroy
      Guess.any?.should be_falsy
    end

  end

  describe '#time_elapsed' do
    it 'returns the age with a precision of seconds in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      stub(Time).now { Time.utc(2001, 2, 2, 1, 1, 1) }
      photo.time_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second'
    end
  end

  describe '#mapped' do
    it "returns false if the photo is not mapped" do
      build(:photo).mapped?.should == false
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 12).mapped?.should == true
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 11).mapped?.should == false
    end

    it "returns false even if the photo is auto-mapped" do
      build(:photo, inferred_latitude: 37, inferred_longitude: -122).mapped?.should == false
    end

  end

  describe '#mapped_or_automapped' do
    it "returns false if the photo is not mapped" do
      build(:photo).mapped_or_automapped?.should == false
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 12).mapped_or_automapped?.should == true
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 11).mapped_or_automapped?.should == false
    end

    it "returns true if the photo is auto-mapped" do
      build(:photo, inferred_latitude: 37, inferred_longitude: -122).mapped_or_automapped?.should == true
    end

  end

end
