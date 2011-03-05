require 'spec_helper'

describe ScoreReport do
  describe '#previous_report' do
    it { should belong_to :previous_report }
    it { should have_one :next_report }
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
