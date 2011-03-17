require 'spec_helper'

describe Admin::PhotosHelper do
  describe 'ago' do
    it "returns 'a moment ago' if the time is < 1 second ago" do
      stub(Time).now { Time.utc(2011) }
      helper.ago(Time.utc(2011)).should == 'a moment ago'
    end

    it "returns 'n seconds ago' if the time is < 1 minute ago " do
      stub(Time).now { Time.utc(2011, 1, 1, 0, 0, 1) }
      helper.ago(Time.utc(2011)).should == '1 second ago'
    end

    it "pluralizes seconds" do
      stub(Time).now { Time.utc(2011, 1, 1, 0, 0, 2) }
      helper.ago(Time.utc(2011)).should == '2 seconds ago'
    end

    it "returns 'n minutes ago' if the time is < 1 hour ago" do
      stub(Time).now { Time.utc(2011, 1, 1, 0, 1, 0) }
      helper.ago(Time.utc(2011)).should == '1 minute ago'
    end

    it "pluralizes minutes" do
      stub(Time).now { Time.utc(2011, 1, 1, 0, 2, 0) }
      helper.ago(Time.utc(2011)).should == '2 minutes ago'
    end

    it "wraps minutes" do
      stub(Time).now { Time.utc(2011) }
      helper.ago(Time.utc(2010, 12, 31, 23, 59, 0)).should == '1 minute ago'
    end

    it "returns 'n hours ago' if the time is < 1 day ago" do
      stub(Time).now { Time.utc(2011, 1, 1, 1, 0, 0) }
      helper.ago(Time.utc(2011)).should == '1 hour ago'
    end

    it "pluralizes hours" do
      stub(Time).now { Time.utc(2011, 1, 1, 2, 0, 0) }
      helper.ago(Time.utc(2011)).should == '2 hours ago'
    end

    it "wraps hours" do
      stub(Time).now { Time.utc(2011) }
      helper.ago(Time.utc(2010, 12, 31, 23, 0, 0)).should == '1 hour ago'
    end

    it "returns 'n days ago' if the time is < 1 month ago" do
      stub(Time).now { Time.utc(2011, 1, 2, 0, 0, 0) }
      helper.ago(Time.utc(2011)).should == '1 day ago'
    end

    it "pluralizes days" do
      stub(Time).now { Time.utc(2011, 1, 3, 0, 0, 0) }
      helper.ago(Time.utc(2011)).should == '2 days ago'
    end

    it "wraps days" do
      stub(Time).now { Time.utc(2011) }
      helper.ago(Time.utc(2010, 12, 31, 0, 0, 0)).should == '1 day ago'
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
