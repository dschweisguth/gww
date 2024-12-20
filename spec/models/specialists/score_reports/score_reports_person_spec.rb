describe ScoreReportsPerson do
  describe '.all_before' do
    it "returns all people who posted before the given date" do
      photo = create :score_reports_photo, dateadded: Time.utc(2011)
      expect(ScoreReportsPerson.all_before(Time.utc(2011))).to eq([photo.person])
    end

    it "returns all people who guessed before the given date" do
      guess = create :score_reports_guess, added_at: Time.utc(2011)
      expect(ScoreReportsPerson.all_before(Time.utc(2011))).to eq([guess.person])
    end

    it "ignores people who did neither" do
      create :score_reports_person
      expect(ScoreReportsPerson.all_before(Time.utc(2011))).to eq([])
    end

    it "ignores people who only posted after the given date" do
      create :score_reports_photo, dateadded: Time.utc(2012)
      expect(ScoreReportsPerson.all_before(Time.utc(2011))).to eq([])
    end

    it "returns all people who only guessed after the given date" do
      create :score_reports_guess, added_at: Time.utc(2012)
      expect(ScoreReportsPerson.all_before(Time.utc(2011))).to eq([])
    end

  end

  describe '.by_score' do
    it "groups people by score" do
      person1 = create :score_reports_person
      person2 = create :score_reports_person
      expect(ScoreReportsPerson.by_score([person1, person2], Time.utc(2011))).to eq(0 => [person1, person2])
    end

    it "adds up guesses" do
      person = create :score_reports_person
      create :score_reports_guess, person: person, added_at: Time.utc(2011)
      create :score_reports_guess, person: person, added_at: Time.utc(2011)
      expect(ScoreReportsPerson.by_score([person], Time.utc(2011))).to eq(2 => [person])
    end

    it "ignores guesses from after the report date" do
      guess = create :score_reports_guess, added_at: Time.utc(2012)
      expect(ScoreReportsPerson.by_score([guess.person], Time.utc(2011))).to eq(0 => [guess.person])
    end

  end

  describe '.add_change_in_standings' do
    let(:person) { create :score_reports_person, post_count: 1, previous_post_count: 1 }

    it "says nothing to a non-new guesser whose standing didn't change" do
      adds_change(
        [person],
        { 2 => [person] },
        { 1 => [person] },
        '')
    end

    it "congratulates a new guesser" do
      adds_change(
        [person],
        { 1 => [person] },
        { 0 => [person] },
        'scored his or her first point. Congratulations!')
    end

    it "welcomes a new guesser who has not previously posted" do
      person.previous_post_count = 0
      adds_change(
        [person],
        { 1 => [person] },
        { 0 => [person] },
        'scored his or her first point. Congratulations, and welcome to GWSF!')
    end

    it "mentions a new guesser's points after the first" do
      adds_change(
        [person],
        { 2 => [person] },
        { 0 => [person] },
        'scored his or her first point (and 1 more). Congratulations!')
    end

    it "mentions climbing" do
      other = create :score_reports_person
      adds_change(
        [person, other],
        { 3 => [person], 2 => [other] },
        { 2 => [other], 1 => [person] },
        "climbed from 2nd to 1st place, passing #{other.username}")
    end

    it "says jumped if the guesser climbed more than one place" do
      other2 = create :score_reports_person
      other3 = create :score_reports_person
      adds_change(
        [person, other2, other3],
        { 4 => [person], 3 => [other2], 2 => [other3] },
        { 3 => [other2], 2 => [other3], 1 => [person] },
        'jumped from 3rd to 1st place, passing 2 other players')
    end

    it "indicates a new tie" do
      other2 = create :score_reports_person
      adds_change(
        [person, other2],
        { 2 => [other2, person] },
        { 2 => [other2], 1 => [person] },
        "climbed from 2nd to 1st place, tying #{other2.username}")
    end

    it "doesn't name names if the guesser is tied with more than one other person" do
      other2 = create :score_reports_person
      other3 = create :score_reports_person
      adds_change(
        [person, other2, other3],
        { 2 => [other2, other3, person] },
        { 2 => [other2, other3], 1 => [person] },
        'jumped from 3rd to 1st place, tying 2 other players')
    end

    it "handles passing and tying at the same time" do
      other2 = create :score_reports_person
      other3 = create :score_reports_person
      adds_change(
        [person, other2, other3],
        { 3 => [person, other2], 2 => [other3] },
        { 3 => [other2], 2 => [other3], 1 => [person] },
        "jumped from 3rd to 1st place, passing #{other3.username} and tying #{other2.username}")
    end

    it "notes numeric milestones" do
      adds_change(
        [person],
        { 100 => [person] },
        { 99 => [person] },
        'Congratulations on reaching 100 points!')
    end

    it "says passing instead of reaching when appropriate" do
      adds_change(
        [person],
        { 101 => [person] },
        { 99 => [person] },
        'Congratulations on passing 100 points!')
    end

    ScoreReportsPerson::CLUBS.each do |club, url|
      it "welcomes the guesser to the #{club} club" do
        adds_change(
          [person],
          { club => [person] },
          { club - 1 => [person] },
          "Welcome to <a href=\"#{url}\">the #{club} Club</a>!")
      end
    end

    it "welcomes the guesser to the top ten" do
      others = create_list :score_reports_person, 10
      others_by_score = {}
      others.each_with_index { |other, i| others_by_score[i + 2] = [other] }
      adds_change(
        [person, *others],
        others_by_score.merge(12 => [person]),
        others_by_score.merge(1 => [person]),
        'jumped from 11th to 1st place. Welcome to the top ten!')
    end

    it "congratulates on multiple achievements" do
      others = create_list :score_reports_person, 10
      others_by_score = {}
      others.each_with_index { |other, i| others_by_score[i + 2] = [other] }
      adds_change(
        [person, *others],
        others_by_score.merge(100 => [person]),
        others_by_score.merge(1 => [person]),
        'jumped from 11th to 1st place. Congratulations on reaching 100 points! ' \
          'Welcome to <a href="https://www.flickr.com/photos/inkvision/2976263709/">the 21 Club</a>! ' \
          'Welcome to the top ten!')
    end

    def adds_change(people, people_by_score, people_by_previous_score, expected_change)
      previous_report_date = Time.utc(2010)
      allow(ScoreReportsPerson).to receive(:by_score).with(people, previous_report_date).and_return(people_by_previous_score)
      allow(ScoreReportsPhoto).to receive(:add_posts).with people, previous_report_date, :previous_post_count
      guessers = [[person, []]]
      ScoreReportsPerson.add_change_in_standings people_by_score, people, previous_report_date, guessers
      expect(person.change_in_standing).to eq(expected_change)
    end

  end

  describe '.add_score_and_place' do
    it "adds their place to each person" do
      person = create :score_reports_person
      people_by_score = { 0 => [person] }
      ScoreReportsPerson.add_score_and_place people_by_score, :score, :place
      expect(person.score).to eq(0)
      expect(person.place).to eq(1)
    end

    it "gives a lower (numerically greater) place to people with lower scores" do
      first = create :score_reports_person
      second = create :score_reports_person
      people_by_score = { 1 => [first], 0 => [second] }
      ScoreReportsPerson.add_score_and_place people_by_score, :score, :place
      expect(first.place).to eq(1)
      expect(second.place).to eq(2)
    end

    it "handles ties" do
      tied1 = create :score_reports_person
      tied2 = create :score_reports_person
      people_by_score = { 0 => [tied1, tied2] }
      ScoreReportsPerson.add_score_and_place people_by_score, :score, :place
      expect(tied1.place).to eq(1)
      expect(tied2.place).to eq(1)
    end

    it "counts the number of people above one, not the number of scores above one" do
      tied1 = create :score_reports_person
      tied2 = create :score_reports_person
      third = create :score_reports_person
      people_by_score = { 1 => [tied1, tied2], 0 => [third] }
      ScoreReportsPerson.add_score_and_place people_by_score, :score, :place
      expect(third.place).to eq(3)
    end

  end

end
