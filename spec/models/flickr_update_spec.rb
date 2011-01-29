require 'spec_helper'

describe FlickrUpdate do
  describe '.new' do
    it 'creates a valid object given all required attributes' do
      FlickrUpdate.new(:member_count => 0).should be_valid
    end

    it 'creates an invalid object if member_count is missing' do
      FlickrUpdate.new().should_not be_valid
    end

  end

end
