describe PersonPeopleSupport do
  describe '.autocompletions' do
    let(:person) { create :person }

    it "matches a username" do
      expect(Person.autocompletions(person.username.slice(0, 3))).
        to eq([{ value: person.username, label: person.autocompletion_label }])
    end

    it "matches a real name" do
      expect(Person.autocompletions(person.realname.slice(0, 3))).
        to eq([{ value: person.username, label: person.autocompletion_label }])
    end

    it "doesn't match if it shouldn't" do
      expect(Person.autocompletions("abc")).to eq([])
    end

  end

  describe '.find_by_multiple_fields' do
    let(:person) { create :person }

    it "finds a person by username" do
      expect(Person.find_by_multiple_fields(person.username)).to eq(person)
    end

    it "finds a person by flickrid" do
      expect(Person.find_by_multiple_fields(person.flickrid)).to eq(person)
    end

    it "finds a person by GWW ID" do
      expect(Person.find_by_multiple_fields(person.id.to_s)).to eq(person)
    end

    it "punts back to the home page" do
      expect(Person.find_by_multiple_fields('xxx')).to be_nil
    end

  end

  describe '.nemeses' do
    it "lists guessers and their favorite posters" do
      guesser, favorite_poster = make_potential_favorite_poster(10, 15)
      nemeses = Person.nemeses
      expect(nemeses).to eq([guesser])
      nemesis = nemeses[0]
      expect(nemesis.poster).to eq(favorite_poster)
      expect(nemesis.bias).to eq(2.5)
    end

    it "ignores less than #{Person::MIN_GUESSES_FOR_FAVORITE} guesses" do
      make_potential_favorite_poster(9, 15)
      expect(Person.nemeses).to eq([])
    end

  end

  describe '.top_guessers' do
    let(:report_time) { Time.local 2011, 1, 3 }
    let(:report_day) { report_time.beginning_of_day }

    it "returns a structure of scores by day, week, month and year" do
      expected = expected_periods_for_one_guess_at_report_time
      guess = create :guess, commented_at: report_time
      (0..3).each { |division| expected[division][0].scores[1] = [guess.person] }
      expect(Person.top_guessers(report_time)).to eq(expected)
    end

    it "handles multiple guesses in the same period" do
      expected = expected_periods_for_one_guess_at_report_time
      guesser = create :person
      create :guess, person: guesser, commented_at: report_time
      create :guess, person: guesser, commented_at: report_time + 1.minute
      (0..3).each { |division| expected[division][0].scores[2] = [guesser] }
      expect(Person.top_guessers(report_time)).to eq(expected)
    end

    it "handles multiple guessers with the same scores in the same periods" do
      expected = expected_periods_for_one_guess_at_report_time
      guess1 = create :guess, commented_at: report_time
      guess2 = create :guess, commented_at: report_time
      guessers = [guess1.person, guess2.person].sort_by { |guesser| guesser.username.downcase }
      (0..3).each { |division| expected[division][0].scores[1] = guessers }
      expect(Person.top_guessers(report_time)).to eq(expected)
    end

    def expected_periods_for_one_guess_at_report_time
      [
        (0..6).map { |i| Period.starting_at report_day - i.days, 1.day },
        [Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day)] +
          (0..4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [Period.new(report_day.beginning_of_month, report_day + 1.day)] +
          (0..11).map { |i| Period.starting_at report_day.beginning_of_month - (i + 1).months, 1.month },
        [Period.new(report_day.beginning_of_year, report_day + 1.day)]
      ]
    end

    it "handles previous years" do
      expected = [
        (0..6).map { |i| Period.starting_at report_day - i.days, 1.day },
        [Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day)] +
          (0..4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [Period.new(report_day.beginning_of_month, report_day + 1.day)] +
          (0..11).map { |i| Period.starting_at report_day.beginning_of_month - (i + 1).months, 1.month },
        [Period.new(report_day.beginning_of_year, report_day + 1.day),
         Period.starting_at(report_day.beginning_of_year - 1.year, 1.year)]
      ]
      guess = create :guess, commented_at: Time.local(2010, 1, 1).getutc
      expected[2][12].scores[1] = [guess.person]
      expected[3][1].scores[1] = [guess.person]
      expect(Person.top_guessers(report_time)).to eq(expected)
    end

  end

  describe '#autocompletion_label' do
    it "returns 'username (real name)' for a user that has a real name" do
      person = build :person
      expect(person.autocompletion_label).to eq("#{person.username} (#{person.realname})")
    end

    it "returns 'username' for a user that has no real name" do
      person = build :person, realname: nil
      expect(person.autocompletion_label).to eq(person.username)
    end

    it "returns 'username' for a user whose username and real name are identical" do
      person = build :person, username: "the same string", realname: "the same string"
      expect(person.autocompletion_label).to eq(person.username)
    end

  end

  describe '#guesses_with_associations_ordered_by_comments' do
    it "returns a person's guesses with their photos and the photos' people" do
      guess = create :guess
      guesses = guess.person.guesses_with_associations_ordered_by_comments
      expect(guesses).to eq([guess])
      expect(guesses[0].photo).to eq(guess.photo)
      expect(guesses[0].photo.person).to eq(guess.photo.person)
    end
  end

  describe '#paginated_commented_photos' do
    let(:person) { create :person }

    it "returns the photos commented on by a given user" do
      comment = create :comment, flickrid: person.flickrid, username: person.username
      expect(person.paginated_commented_photos(1)).to eq([comment.photo])
    end

    it "ignores photos commented on by another user" do
      create :comment
      expect(person.paginated_commented_photos(1)).to eq([])
    end

    it "paginates" do
      create_list :comment, 2, flickrid: person.flickrid, username: person.username
      expect(person.paginated_commented_photos(1, 2).length).to eq(2)
    end

    it "returns each photo only once, even if the person commented on it more than once" do
      photo = create :photo
      create :comment, photo: photo, flickrid: person.flickrid, username: person.username
      create :comment, photo: photo, flickrid: person.flickrid, username: person.username
      expect(person.paginated_commented_photos(1)).to eq([photo])
    end

    it "sorts the most recently updated photos first" do
      photo1 = create :photo, lastupdate: 2.days.ago
      create :comment, photo: photo1, flickrid: person.flickrid, username: person.username
      photo2 = create :photo, lastupdate: 1.days.ago
      create :comment, photo: photo2, flickrid: person.flickrid, username: person.username
      expect(person.paginated_commented_photos(1)).to eq([photo2, photo1])
    end

  end

end
