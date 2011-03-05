require 'spec_helper'

describe ScoreReport do
  describe '#previous_report' do
    it { should belong_to :previous_report }
    it { should have_one :next_report }
  end

  describe '.all_with_guess_counts' do
    it "counts the guesses in the first score report" do
      Guess.make :added_at => Time.utc(2011)
      report = ScoreReport.make :created_at => Time.utc(2011)
      reports = ScoreReport.all_with_guess_counts
      reports.should == [ report ]
      reports[0][:count].should == 1
    end

    it "counts the guesses in a non-first score report" do
      Guess.make :added_at => Time.utc(2011)
      ScoreReport.make :created_at => Time.utc(2010)
      report1 = ScoreReport.make :created_at => Time.utc(2011)
      reports = ScoreReport.all_with_guess_counts
      reports.should == [ report1 ]
      reports[0][:count].should == 1
    end

  end

  describe '.previous' do
    it "returns the report immediately preceding the given date" do
      previous = ScoreReport.make :created_at => Time.utc(2010)
      ScoreReport.make :created_at => Time.utc(2009)
      ScoreReport.previous(Time.utc(2011)).should == previous
    end

    it "ignores reports on or after the given date" do
      ScoreReport.make :created_at => Time.utc(2011)
      ScoreReport.previous(Time.utc(2011)).should be_nil
    end

  end
end
