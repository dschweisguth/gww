require 'spec_helper'

describe ScoreReport do
  describe '.preceding' do
    it "returns the report immediately preceding the given date" do
      preceding = ScoreReport.make :created_at => Time.utc(2010)
      ScoreReport.make :created_at => Time.utc(2009)
      ScoreReport.preceding(Time.utc(2011)).should == preceding
    end

    it "ignores reports on or after the given date" do
      ScoreReport.make :created_at => Time.utc(2011)
      ScoreReport.preceding(Time.utc(2011)).should be_nil
    end

  end
end
