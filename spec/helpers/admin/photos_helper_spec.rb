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

    it "returns '1 minute ago' if 1 minute <= time < 2 minutes" do
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
