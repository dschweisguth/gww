describe ScoreReport do

  describe '.guess_counts' do
    before do
      create :guess, added_at: Time.utc(2011)
    end

    it "counts the guesses in the first score report" do
      report = create :score_report, created_at: Time.utc(2011)
      ScoreReport.guess_counts.should == { report.id => 1 }
    end

    it "counts the guesses in a non-first score report" do
      create :score_report, created_at: Time.utc(2010)
      report1 = create :score_report, created_at: Time.utc(2011)
      ScoreReport.guess_counts.should == { report1.id => 1 }
    end

  end

  describe '.revelation_counts' do
    before do
      create :revelation, added_at: Time.utc(2011)
    end

    it "counts the revelations in the first score report" do
      report = create :score_report, created_at: Time.utc(2011)
      ScoreReport.revelation_counts.should == { report.id => 1 }
    end

    it "counts the revelations in a non-first score report" do
      create :score_report, created_at: Time.utc(2010)
      report1 = create :score_report, created_at: Time.utc(2011)
      ScoreReport.revelation_counts.should == { report1.id => 1 }
    end

  end

  describe '.previous' do
    it "returns the report immediately preceding the given date" do
      previous = create :score_report, created_at: Time.utc(2010)
      create :score_report, created_at: Time.utc(2009)
      ScoreReport.previous(Time.utc(2011)).should == previous
    end

    it "ignores reports on or after the given date" do
      create :score_report, created_at: Time.utc(2011)
      ScoreReport.previous(Time.utc(2011)).should be_nil
    end

  end

end
