require 'spec_helper'

describe Admin::PhotosHelper do
  describe 'ago' do
    it "returns 'a moment ago' if time < 1 second ago" do
      ago_returns 2011, 2011, 'a moment ago'
    end

    it "returns 'n seconds ago' if 1 second ago <= time < 1 minute ago " do
      ago_returns [ 2011, 1, 1, 0, 0, 1 ], 2011, '1 second ago'
    end

    it "pluralizes seconds" do
      ago_returns [ 2011, 1, 1, 0, 0, 2 ], 2011, '2 seconds ago'
    end

    it "returns 'n minutes ago' if 1 minute ago <= time < 1 hour ago" do
      ago_returns [ 2011, 1, 1, 0, 1, 0 ], 2011, '1 minute ago'
    end

    it "pluralizes minutes" do
      ago_returns [ 2011, 1, 1, 0, 2, 0 ], 2011, '2 minutes ago'
    end

    it "wraps minutes" do
      ago_returns 2011, [ 2010, 12, 31, 23, 59, 0 ], '1 minute ago'
    end

    it "returns 'n hours ago' if 1 hour ago <= time < 1 day ago" do
      ago_returns [ 2011, 1, 1, 1, 0, 0 ], 2011, '1 hour ago'
    end

    it "pluralizes hours" do
      ago_returns [ 2011, 1, 1, 2, 0, 0 ], 2011, '2 hours ago'
    end

    it "wraps hours" do
      ago_returns 2011, [ 2010, 12, 31, 23, 0, 0 ], '1 hour ago'
    end

    it "returns 'n days ago' if 1 day ago <= time < 1 week ago" do
      ago_returns [ 2011, 1, 2, 0, 0, 0 ], 2011, '1 day ago'
    end

    it "pluralizes days" do
      ago_returns [ 2011, 1, 3, 0, 0, 0 ], 2011, '2 days ago'
    end

    it "wraps days" do
      ago_returns 2011, [ 2010, 12, 31, 0, 0, 0 ], '1 day ago'
    end

    it "returns 'n weeks ago' if 1 week ago <= time < 1 month ago" do
      ago_returns [ 2011, 1, 8, 0, 0, 0 ], 2011, '1 week ago'
    end
    
    it "rounds down weeks" do
      ago_returns [ 2011, 1, 9, 0, 0, 0 ], 2011, '1 week ago'
    end

    it "pluralizes weeks" do
      ago_returns [ 2011, 1, 15, 0, 0, 0 ], 2011, '2 weeks ago'
    end

    it "wraps weeks" do
      ago_returns 2011, [ 2010, 12, 25, 0, 0, 0 ], '1 week ago'
    end

    it "returns 'n months ago' if 1 month ago <= time" do
      ago_returns [ 2011, 2, 1, 0, 0, 0 ], 2011, '1 month ago'
    end

    it "pluralizes months" do
      ago_returns [ 2011, 3, 1, 0, 0, 0 ], 2011, '2 months ago'
    end

    it "wraps months" do
      ago_returns 2011, [ 2010, 12, 1, 0, 0, 0 ], '1 month ago'
    end

    it "incorporates years into months" do
      ago_returns 2011, 2010, '12 months ago'
    end

    def ago_returns(now, time, expected)
      stub(Time).now { Time.utc(*now) }
      helper.ago(Time.utc(*time)).should == expected
    end

  end

  describe '#wrap_if' do
    it "wraps if the condition is true" do
      helper.wrap_if(true, '<begin>', '<end>') { 'content' }.should == '<begin>content<end>'
    end

    it "doesn't wrap if the condition is false" do
      helper.wrap_if(false, '<begin>', '<end>') { 'content' }.should == 'content'
    end

  end

end