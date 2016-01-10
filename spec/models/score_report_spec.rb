describe ScoreReport do
  describe '.guess_counts' do
    before do
      create :guess, added_at: Time.utc(2011)
    end

    it "counts the guesses in the first score report" do
      report = create :score_report, created_at: Time.utc(2011)
      expect(ScoreReport.guess_counts).to eq(report.id => 1)
    end

    it "counts the guesses in a non-first score report" do
      create :score_report, created_at: Time.utc(2010)
      report1 = create :score_report, created_at: Time.utc(2011)
      expect(ScoreReport.guess_counts).to eq(report1.id => 1)
    end

  end

  describe '.revelation_counts' do
    before do
      create :revelation, added_at: Time.utc(2011)
    end

    it "counts the revelations in the first score report" do
      report = create :score_report, created_at: Time.utc(2011)
      expect(ScoreReport.revelation_counts).to eq(report.id => 1)
    end

    it "counts the revelations in a non-first score report" do
      create :score_report, created_at: Time.utc(2010)
      report1 = create :score_report, created_at: Time.utc(2011)
      expect(ScoreReport.revelation_counts).to eq(report1.id => 1)
    end

  end

  describe '.previous' do
    it "returns the report immediately preceding the given date" do
      previous = create :score_report, created_at: Time.utc(2010)
      create :score_report, created_at: Time.utc(2009)
      expect(ScoreReport.previous(Time.utc(2011))).to eq(previous)
    end

    it "ignores reports on or after the given date" do
      create :score_report, created_at: Time.utc(2011)
      expect(ScoreReport.previous(Time.utc(2011))).to be_nil
    end

  end

  describe '.latest' do
    it "returns the most recent score report" do
      create :score_report
      latest = create :score_report
      expect(ScoreReport.latest).to eq(latest)
    end
  end

end
