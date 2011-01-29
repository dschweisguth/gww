require 'spec_helper'
require 'model_factory'

describe FlickrUpdate do
  it "requires member_count" do
    should validate_presence_of :member_count
  end

  it "doesn't allow member_count to change" do
    should have_readonly_attribute :member_count
  end

  describe '.new' do
    it 'creates a valid object given all required attributes' do
      FlickrUpdate.new(:member_count => 0).should be_valid
    end
  end

  describe '.latest' do
    it 'returns the most recent update' do
      FlickrUpdate.create_for_test!
      most_recent_update = FlickrUpdate.create_for_test!
      FlickrUpdate.latest.should == most_recent_update
    end
  end

end
