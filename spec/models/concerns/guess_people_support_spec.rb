describe GuessPeopleSupport do
  describe '.mapped_count' do
    it "counts the person's guesses of mapped photos" do
      photo = create :photo, accuracy: 12
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 1
    end

    it "counts the person's guesses of auto-mapped photos" do
      photo = create :photo, inferred_latitude: 37
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 1
    end

    it "ignores others' guesses" do
      photo = create :photo, accuracy: 12
      create :guess, photo: photo
      other_person = create :person
      Guess.mapped_count(other_person.id).should == 0
    end

    it "ignores guesses of unmapped photos" do
      photo = create :photo
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 0
    end

    it "ignores guesses of photos mapped with insufficient accuracy" do
      photo = create :photo, accuracy: 11
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 0
    end

  end

  describe '.find_with_associations' do
    it "returns a person's guesses with their photos and the photos' people" do
      guess = create :guess
      guesses = Guess.find_with_associations guess.person
      guesses.should == [ guess ]
      guesses[0].photo.should == guess.photo
      guesses[0].photo.person.should == guess.photo.person
    end
  end

end
