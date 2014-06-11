describe PersonShowSupport do
  describe '#mapped_photo_count' do
    it "counts mapped photos" do
      photo = create :photo, accuracy: 12
      photo.person.mapped_photo_count.should == 1
    end

    it "counts auto-mapped photos" do
      photo = create :photo, inferred_latitude: 37
      photo.person.mapped_photo_count.should == 1
    end

    it "ignores other people's photos" do
      create :photo, accuracy: 12
      other_person = create :person
      other_person.mapped_photo_count.should == 0
    end

    it "ignores unmapped photos" do
      photo = create :photo
      photo.person.mapped_photo_count.should == 0
    end

    it "ignores photos mapped with an accuracy < 12" do
      photo = create :photo, accuracy: 11
      photo.person.mapped_photo_count.should == 0
    end

  end

  describe '#mapped_guess_count' do
    it "counts the person's guesses of mapped photos" do
      photo = create :photo, accuracy: 12
      guess = create :guess, photo: photo
      guess.person.mapped_guess_count.should == 1
    end

    it "counts the person's guesses of auto-mapped photos" do
      photo = create :photo, inferred_latitude: 37
      guess = create :guess, photo: photo
      guess.person.mapped_guess_count.should == 1
    end

    it "ignores others' guesses" do
      photo = create :photo, accuracy: 12
      create :guess, photo: photo
      other_person = create :person
      other_person.mapped_guess_count.should == 0
    end

    it "ignores guesses of unmapped photos" do
      photo = create :photo
      guess = create :guess, photo: photo
      guess.person.mapped_guess_count.should == 0
    end

    it "ignores guesses of photos mapped with insufficient accuracy" do
      photo = create :photo, accuracy: 11
      guess = create :guess, photo: photo
      guess.person.mapped_guess_count.should == 0
    end

  end

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

  describe '#first_photo' do
    let(:poster) { create :person }

    it "returns the poster's first post" do
      create :photo, person: poster, dateadded: Time.utc(2001)
      first = create :photo, person: poster, dateadded: Time.utc(2000)
      poster.first_photo.should == first
    end

    it "ignores other posters' photos" do
      create :photo
      poster.first_photo.should be_nil
    end

  end

  describe '#most_recent_photo' do
    let(:poster) { create :person }

    it "returns the poster's most recent post" do
      create :photo, person: poster, dateadded: Time.utc(2000)
      most_recent = create :photo, person: poster, dateadded: Time.utc(2001)
      poster.most_recent_photo.should == most_recent
    end

    it "ignores other posters' photos" do
      create :photo
      poster.most_recent_photo.should be_nil
    end

  end

  describe '#oldest_guess' do
    let(:guesser) { create :person }

    it "returns the guesser's guess made the longest after the post" do
      photo1 = create :photo, dateadded: Time.utc(2000)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      guess2 = create :guess, person: guesser, photo: photo2, commented_at: Time.utc(2004)
      oldest = guesser.oldest_guess
      oldest.should == guess2
      oldest.place.should == 1
    end

    it "ignores other players' guesses" do
      create :guess
      guesser.oldest_guess.should be_nil
    end

    it "considers other players' guesses when calculating place" do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      create :guess, photo: photo2, commented_at: Time.utc(2004)
      oldest = guesser.oldest_guess
      oldest.should == guess1
      oldest.place.should == 2
    end

    it "ignores a guess that precedes its post" do
      photo1 = create :photo, dateadded: Time.utc(2001)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2000)
      guesser.oldest_guess.should == nil
    end

  end

  describe '#fastest_guess' do
    let(:guesser) { create :person }

    it "returns the guesser's guess made the fastest after the post" do
      photo1 = create :photo, dateadded: Time.utc(2002)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      guess2 = create :guess, person: guesser, photo: photo2, commented_at: Time.utc(2001)
      fastest = guesser.fastest_guess
      fastest.should == guess2
      fastest.place.should == 1
    end

    it "ignores other players' guesses" do
      create :guess
      guesser.fastest_guess.should be_nil
    end

    it "considers other players' guesses when calculating place" do
      photo1 = create :photo, dateadded: Time.utc(2002)
      guess1 = create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      create :guess, photo: photo2, commented_at: Time.utc(2001)
      fastest = guesser.fastest_guess
      fastest.should == guess1
      fastest.place.should == 2
    end

    it "ignores a guess that precedes its post" do
      photo1 = create :photo, dateadded: Time.utc(2001)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2000)
      guesser.fastest_guess.should == nil
    end

  end

  describe '#guess_of_longest_lasting_post' do
    let(:poster) { create :person }

    it "returns the poster's photo which went unfound the longest" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2000)
      create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, person: poster, dateadded: Time.utc(2002)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      longest_lasting = poster.guess_of_longest_lasting_post
      longest_lasting.should == guess2
      longest_lasting.place.should == 1
    end

    it "ignores guesses of other players' posts" do
      create :photo, person: poster
      create :guess
      poster.guess_of_longest_lasting_post.should be_nil
    end

    it "considers other posters when calculating place" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      create :guess, photo: photo2, commented_at: Time.utc(2004)
      longest_lasting = poster.guess_of_longest_lasting_post
      longest_lasting.should == guess1
      longest_lasting.place.should == 2
    end

    it 'ignores a guess that precedes its post' do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2001)
      create :guess, photo: photo1, commented_at: Time.utc(2000)
      poster.guess_of_longest_lasting_post.should == nil
    end

  end

  describe '#guess_of_shortest_lasting_post' do
    let(:poster) { create :person }

    it "returns the guess of the poster's photo which was made the soonest after the post" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2002)
      create :guess, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, person: poster, dateadded: Time.utc(2000)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2001)
      shortest_lasting = poster.guess_of_shortest_lasting_post
      shortest_lasting.should == guess2
      shortest_lasting.place.should == 1
    end

    it "ignores guesses of other players' posts" do
      create :photo, person: poster
      create :guess
      poster.guess_of_shortest_lasting_post.should be_nil
    end

    it "considers other posters when calculating place" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2002)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      create :guess, photo: photo2, commented_at: Time.utc(2001)
      shortest_lasting = poster.guess_of_shortest_lasting_post
      shortest_lasting.should == guess1
      shortest_lasting.place.should == 2
    end

    it 'ignores a guess that precedes its post' do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2001)
      create :guess, photo: photo1, commented_at: Time.utc(2000)
      poster.guess_of_shortest_lasting_post.should == nil
    end

  end

  describe '#oldest_unfound_photo' do
    let(:poster) { create :person }

    it "returns the poster's oldest unfound" do
      create :photo, person: poster, dateadded: Time.utc(2001)
      first = create :photo, person: poster, dateadded: Time.utc(2000)
      oldest_unfound = poster.oldest_unfound_photo
      oldest_unfound.should == first
      oldest_unfound.place.should == 1
    end

    it "ignores other posters' photos" do
      create :photo
      poster.oldest_unfound_photo.should be_nil
    end

    it "considers unconfirmed photos" do
      photo = create :photo, person: poster, game_status: 'unconfirmed'
      poster.oldest_unfound_photo.should == photo
    end

    it "ignores game statuses other than unfound and unconfirmed" do
      create :photo, person: poster, game_status: 'found'
      poster.oldest_unfound_photo.should be_nil
    end

    it "considers other posters' oldest unfounds when calculating place" do
      create :photo, person: poster, dateadded: Time.utc(2000)
      next_oldest = create :photo, dateadded: Time.utc(2001)
      oldest_unfound = next_oldest.person.oldest_unfound_photo
      oldest_unfound.should == next_oldest
      oldest_unfound.place.should == 2
    end

    it "considers unconfirmed photos when calculating place" do
      create :photo, person: poster, dateadded: Time.utc(2000), game_status: 'unconfirmed'
      next_oldest = create :photo, dateadded: Time.utc(2001)
      oldest_unfound = next_oldest.person.oldest_unfound_photo
      oldest_unfound.should == next_oldest
      oldest_unfound.place.should == 2
    end

    it "ignores other posters' equally old unfounds when calculating place" do
      create :photo, person: poster, dateadded: Time.utc(2001)
      next_oldest = create :photo, dateadded: Time.utc(2001)
      oldest_unfound = next_oldest.person.oldest_unfound_photo
      oldest_unfound.should == next_oldest
      oldest_unfound.place.should == 1
    end

    it "handles a person with no photos" do
      poster.oldest_unfound_photo.should be_nil
    end

  end

  describe '#most_commented_photo' do
    let(:poster) { create :person }

    it "returns the poster's most-commented photo" do
      create :photo, person: poster
      first = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: first
      most_commented = poster.most_commented_photo
      most_commented.should == first
      most_commented.other_user_comments.should == 1
      most_commented.place.should == 1
    end

    it "counts comments" do
      second = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: second
      first = create :photo, person: poster, other_user_comments: 2
      create :comment, photo: first
      create :comment, photo: first
      most_commented = poster.most_commented_photo
      most_commented.should == first
      most_commented.other_user_comments.should == 2
      most_commented.place.should == 1
    end

    it "ignores other posters' photos" do
      photo = create :photo, other_user_comments: 1
      create :comment, photo: photo
      poster.most_commented_photo.should be_nil
    end

    it "considers other posters' photos when calculating place" do
      other_posters_photo = create :photo, other_user_comments: 2
      create :comment, photo: other_posters_photo
      create :comment, photo: other_posters_photo
      photo = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: photo
      poster.most_commented_photo.place.should == 2
    end

    it "ignores other posters' equally commented photos when calculating place" do
      other_posters_photo = create :photo, other_user_comments: 1
      create :comment, photo: other_posters_photo
      photo = create :photo, person: poster, other_user_comments: 1
      create :comment, photo: photo
      poster.most_commented_photo.place.should == 1
    end

    it "handles a person with no photos" do
      poster.most_commented_photo.should be_nil
    end

  end

  describe '#most_viewed_photo' do
    let(:poster) { create :person }

    it "returns the poster's most-viewed photo" do
      create :photo, person: poster
      first = create :photo, person: poster, views: 1
      most_viewed = poster.most_viewed_photo
      most_viewed.should == first
      most_viewed.place.should == 1
    end

    it "ignores other posters' photos" do
      create :photo
      poster.most_viewed_photo.should be_nil
    end

    it "considers other posters' photos when calculating place" do
      create :photo, views: 1
      create :photo, person: poster
      poster.most_viewed_photo.place.should == 2
    end

    it "ignores other posters' equally viewed photos when calculating place" do
      create :photo
      create :photo, person: poster
      poster.most_viewed_photo.place.should == 1
    end

    it "handles a person with no photos" do
      poster.most_viewed_photo.should be_nil
    end

  end

  describe '.most_faved_photo' do
    let(:poster) { create :person }

    it "returns the poster's most-faved photo" do
      create :photo, person: poster
      first = create :photo, person: poster, faves: 1
      most_faved = poster.most_faved_photo
      most_faved.should == first
      most_faved.place.should == 1
    end

    it "ignores other posters' photos" do
      create :photo
      poster.most_faved_photo.should be_nil
    end

    it "considers other posters' photos when calculating place" do
      create :photo, faves: 1
      create :photo, person: poster
      poster.most_faved_photo.place.should == 2
    end

    it "ignores other posters' equally faved photos when calculating place" do
      create :photo
      create :photo, person: poster
      poster.most_faved_photo.place.should == 1
    end

    it "handles a person with no photos" do
      poster.most_faved_photo.should be_nil
    end

  end

  describe '#guesses_with_associations' do
    it "returns a person's guesses with their photos and the photos' people" do
      guess = create :guess
      guesses = guess.person.guesses_with_associations
      guesses.should == [ guess ]
      guesses[0].photo.should == guess.photo
      guesses[0].photo.person.should == guess.photo.person
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

  describe '#photos_with_associations' do
    it "returns the person's photos, with their guesses and the guesses' people" do
      guess = create :guess
      photos = guess.photo.person.photos_with_associations
      photos.should == [ guess.photo ]
      photos[0].guesses.should == [ guess ]
      photos[0].guesses[0].person.should == guess.person
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
