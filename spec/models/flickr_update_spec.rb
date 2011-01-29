require 'spec_helper'
require 'model_factory'

describe FlickrUpdate do
  describe '.new' do
    it 'creates a valid object given all required attributes' do
      FlickrUpdate.new(:member_count => 0).should be_valid
    end

    it 'creates an invalid object if member_count is missing' do
      FlickrUpdate.new.should_not be_valid
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
