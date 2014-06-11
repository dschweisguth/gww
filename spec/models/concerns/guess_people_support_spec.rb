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

  describe '.oldest' do
    let(:guesser) { create :person }

    it "returns the guesser's guess made the longest after the post" do
      photo1 = create :photo, dateadded: Time.utc(2000)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      guess2 = create :guess, person: guesser, photo: photo2, commented_at: Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess2
      oldest.place.should == 1
    end

    it "ignores other players' guesses" do
      create :guess
      Guess.oldest(guesser).should be_nil
    end

    it "considers other players' guesses when calculating place" do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      create :guess, photo: photo2, commented_at: Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess1
      oldest.place.should == 2
    end

    it "ignores a guess that precedes its post" do
      photo1 = create :photo, dateadded: Time.utc(2001)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2000)
      Guess.oldest(guesser).should == nil
    end

  end

  describe '.longest_lasting' do
    let(:poster) { create :person }

    it "returns the poster's photo which went unfound the longest" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2000)
      create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, person: poster, dateadded: Time.utc(2002)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess2
      longest_lasting.place.should == 1
    end

    it "ignores guesses of other players' posts" do
      create :photo, person: poster
      create :guess
      Guess.longest_lasting(poster).should be_nil
    end

    it "considers other posters when calculating place" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      create :guess, photo: photo2, commented_at: Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess1
      longest_lasting.place.should == 2
    end

    it 'ignores a guess that precedes its post' do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2001)
      create :guess, photo: photo1, commented_at: Time.utc(2000)
      Guess.longest_lasting(poster).should == nil
    end

  end

  describe '.fastest' do
    let(:guesser) { create :person }

    it "returns the guesser's guess made the fastest after the post" do
      photo1 = create :photo, dateadded: Time.utc(2002)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      guess2 = create :guess, person: guesser, photo: photo2, commented_at: Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess2
      fastest.place.should == 1
    end

    it "ignores other players' guesses" do
      create :guess
      Guess.fastest(guesser).should be_nil
    end

    it "considers other players' guesses when calculating place" do
      photo1 = create :photo, dateadded: Time.utc(2002)
      guess1 = create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      create :guess, photo: photo2, commented_at: Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess1
      fastest.place.should == 2
    end

    it "ignores a guess that precedes its post" do
      photo1 = create :photo, dateadded: Time.utc(2001)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2000)
      Guess.fastest(guesser).should == nil
    end

  end

  describe '.shortest_lasting' do
    let(:poster) { create :person }

    it "returns the guess of the poster's photo which was made the soonest after the post" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2002)
      create :guess, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, person: poster, dateadded: Time.utc(2000)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess2
      shortest_lasting.place.should == 1
    end

    it "ignores guesses of other players' posts" do
      create :photo, person: poster
      create :guess
      Guess.shortest_lasting(poster).should be_nil
    end

    it "considers other posters when calculating place" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2002)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      create :guess, photo: photo2, commented_at: Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess1
      shortest_lasting.place.should == 2
    end

    it 'ignores a guess that precedes its post' do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2001)
      create :guess, photo: photo1, commented_at: Time.utc(2000)
      Guess.shortest_lasting(poster).should == nil
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
