require 'spec_helper'

describe FlickrUpdate do

  describe '#member_count' do
    it { should validate_presence_of :member_count }
    it { should validate_non_negative_integer :member_count }
    it { should have_readonly_attribute :member_count }
  end

  describe '.latest' do
    it 'returns the most recent update' do
      FlickrUpdate.make!
      most_recent_update = FlickrUpdate.make!
      FlickrUpdate.latest.should == most_recent_update
    end
  end

end
