describe PersonShowSupport do
  describe '#standing' do
    let(:person) { create :person }

    it "returns the person's score position" do
      person.standing.should == [ 1, false ]
    end

    it "considers other players' scores" do
      create :guess
      person.standing.should == [ 2, false ]
    end

    it "detects ties" do
      create :guess, person: person
      create :guess
      person.standing.should == [ 1, true ]
    end

  end

  describe '#posts_standing' do
    let(:person) { create :person }

    it "returns the person's post position" do
      person.posts_standing.should == [ 1, false ]
    end

    it "considers other players' posts" do
      create :photo
      person.posts_standing.should == [ 2, false ]
    end

    it "detects ties" do
      create :photo, person: person
      create :photo
      person.posts_standing.should == [ 1, true ]
    end

  end

  describe '#first_guess' do
    let(:guesser) { create :person }

    it "returns the guesser's first guess" do
      create :guess, person: guesser, commented_at: Time.utc(2001)
      first = create :guess, person: guesser, commented_at: Time.utc(2000)
      guesser.first_guess.should == first
    end

    it "ignores other players' guesses" do
      create :guess
      guesser.first_guess.should be_nil
    end

  end

  describe '#most_recent_guess' do
    let(:guesser) { create :person }

    it "returns the guesser's most recent guess" do
      create :guess, person: guesser, commented_at: Time.utc(2000)
      most_recent = create :guess, person: guesser, commented_at: Time.utc(2001)
      guesser.most_recent_guess.should == most_recent
    end

    it "ignores other players' guesses" do
      create :guess
      guesser.most_recent_guess.should be_nil
    end

  end

  describe '#favorite_posters' do
    it "lists the posters which this person has guessed #{Person::MIN_BIAS_FOR_FAVORITE} or more times as often as this person has guessed all posts" do
      guesser, favorite_poster = make_potential_favorite_poster(10, 15)
      favorite_posters = guesser.favorite_posters
      favorite_posters.should == [ favorite_poster ]
      favorite_posters[0].bias.should == Person::MIN_BIAS_FOR_FAVORITE
    end

    it "ignores a poster which this person has guessed less than #{Person::MIN_BIAS_FOR_FAVORITE} times as often as this person has guessed all posts" do
      #noinspection RubyUnusedLocalVariable
      guesser, favorite_poster = make_potential_favorite_poster(10, 14)
      guesser.favorite_posters.should == []
    end

    it "ignores a poster which this person has guessed less than #{Person::MIN_GUESSES_FOR_FAVORITE} times" do
      #noinspection RubyUnusedLocalVariable
      guesser, favorite_poster = make_potential_favorite_poster(9, 15)
      guesser.favorite_posters.should == []
    end

  end

  describe '#favoring_guessers' do
    it "lists the guessers who have guessed this person #{Person::MIN_BIAS_FOR_FAVORITE} or more times as often as those guessers have guessed all posts" do
      devoted_guesser, poster = make_potential_favorite_poster(10, 15)
      favoring_guessers = poster.favoring_guessers
      favoring_guessers.should == [ devoted_guesser ]
      favoring_guessers[0].bias.should == Person::MIN_BIAS_FOR_FAVORITE
    end

    it "ignores a guesser who has guessed this person less than #{Person::MIN_BIAS_FOR_FAVORITE} times as often as that guesser has guessed all posts" do
      #noinspection RubyUnusedLocalVariable
      devoted_guesser, poster = make_potential_favorite_poster(10, 14)
      poster.favoring_guessers.should == []
    end

    it "ignores a guesser who has guessed this person less than #{Person::MIN_GUESSES_FOR_FAVORITE} times" do
      #noinspection RubyUnusedLocalVariable
      devoted_guesser, poster = make_potential_favorite_poster(9, 15)
      poster.favoring_guessers.should == []
    end

  end

end
