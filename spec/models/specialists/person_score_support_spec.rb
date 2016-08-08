describe ScoreReportsPerson do
  describe '.high_scorers' do
    let(:report_date) { Time.utc(2011) }

    it "returns the highest scorers in the given previous # of days" do
      person = create :score_reports_person
      create_list :score_reports_guess, 2, person: person, commented_at: report_date, added_at: report_date
      high_scorers_returns report_date, 1, person, 2
    end

    it "returns only the top 3 high scorers if there is not a tie for third place" do
      person_with_guesses 2
      person2 = person_with_guesses 3
      person3 = person_with_guesses 4
      person4 = person_with_guesses 5
      expect(ScoreReportsPerson.high_scorers(report_date, 1)).to eq([person4, person3, person2])
    end

    it "returns all ties for third place" do
      person1 = person_with_guesses 3, username: 'b'
      person2 = person_with_guesses 3, username: 'a'
      person3 = person_with_guesses 4
      person4 = person_with_guesses 5
      expect(ScoreReportsPerson.high_scorers(report_date, 1)).to eq([person4, person3, person2, person1])
    end

    it "ignores guesses made before the reporting period" do
      person = person_with_guesses 2
      create :score_reports_guess, person: person, commented_at: report_date - 1.day - 1.second, added_at: report_date
      high_scorers_returns report_date, 1, person, 2
    end

    it "ignores guesses added after the reporting period" do
      person = person_with_guesses 2
      create :score_reports_guess, person: person, commented_at: report_date, added_at: report_date + 1.second
      high_scorers_returns report_date, 1, person, 2
    end

    def high_scorers_returns(now, for_the_past_n_days, person, score)
      high_scorers = ScoreReportsPerson.high_scorers now, for_the_past_n_days
      expect(high_scorers).to eq([person])
      expect(high_scorers[0].high_score).to eq(score)
    end

    it "ignores scores of 1" do
      create :score_reports_guess, commented_at: report_date, added_at: report_date
      expect(ScoreReportsPerson.high_scorers(report_date, 1)).to eq([])
    end

    it "ignores scores of 0" do
      create :score_reports_photo
      expect(ScoreReportsPerson.high_scorers(report_date, 1)).to eq([])
    end

    def person_with_guesses(guess_count, options = {})
      person = create :score_reports_person, options
      create_list :score_reports_guess, guess_count, person: person, commented_at: report_date, added_at: report_date
      person
    end

  end

  describe '.top_posters' do
    let(:report_date) { Time.utc(2011) }

    it "returns the most frequent posters in the given previous # of days" do
      person = create :score_reports_person
      create_list :score_reports_photo, 2, person: person, dateadded: report_date
      top_posters_returns report_date, 1, person, 2
    end

    it "returns only the top 3 frequent posters if there is not a tie for third place" do
      person_with_posts 2
      person2 = person_with_posts 3
      person3 = person_with_posts 4
      person4 = person_with_posts 5
      expect(ScoreReportsPerson.top_posters(report_date, 1)).to eq([person4, person3, person2])
    end

    it "returns all ties for third place" do
      person1 = person_with_posts 3, username: 'b'
      person2 = person_with_posts 3, username: 'a'
      person3 = person_with_posts 4
      person4 = person_with_posts 5
      expect(ScoreReportsPerson.top_posters(report_date, 1)).to eq([person4, person3, person2, person1])
    end

    it "ignores photos posted before the reporting period" do
      person = person_with_posts 2
      create :score_reports_photo, person: person, dateadded: report_date - 1.day - 1.second
      top_posters_returns report_date, 1, person, 2
    end

    it "ignores photos posted after the reporting period" do
      person = person_with_posts 2
      create :score_reports_photo, person: person, dateadded: report_date + 1.second
      top_posters_returns report_date, 1, person, 2
    end

    def top_posters_returns(now, for_the_past_n_days, person, post_count)
      top_posters = ScoreReportsPerson.top_posters now, for_the_past_n_days
      expect(top_posters).to eq([person])
      expect(top_posters[0].top_post_count).to eq(post_count)
    end

    it "ignores post counts of 1" do
      create :score_reports_photo, dateadded: report_date
      expect(ScoreReportsPerson.top_posters(report_date, 1)).to eq([])
    end

    it "ignores post counts of 0" do
      create :score_reports_person
      expect(ScoreReportsPerson.top_posters(report_date, 1)).to eq([])
    end

    def person_with_posts(post_count, options = {})
      person = create :score_reports_person, options
      create_list :score_reports_photo, post_count, person: person, dateadded: report_date
      person
    end

  end

end
