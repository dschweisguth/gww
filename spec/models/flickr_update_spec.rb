require 'spec_helper'

describe FlickrUpdate do
  describe '.new' do
    it 'creates a valid object given all required attributes' do
      update = FlickrUpdate.new()
      # What do you know; member_count defaults to 0, possibly due to the default in the database
      update.member_count.should == 0
      update.should be_valid
    end

    it 'creates an invalid object if member_count is missing' do
      FlickrUpdate.new(:member_count => nil).should_not be_valid
    end

  end

end
