require 'spec_helper'

describe FlickrUpdate do

  describe '#member_count' do
    it { should validate_presence_of :member_count }
    it { should validate_numericality_of :member_count }
    it "requires member_count >= 0" do
      FlickrUpdate.new(:member_count => -1).should_not be_valid
    end
    it "requires integral member_count" do
      FlickrUpdate.new(:member_count => 0.1).should_not be_valid
    end
    it { should have_readonly_attribute :member_count }
  end

  describe '.latest' do
    it 'returns the most recent update' do
      FlickrUpdate.create_for_test!
      most_recent_update = FlickrUpdate.create_for_test!
      FlickrUpdate.latest.should == most_recent_update
    end
  end

end
