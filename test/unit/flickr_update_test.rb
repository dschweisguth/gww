require File.dirname(__FILE__) + '/../test_helper'

class FlickrUpdateTest < Test::Unit::TestCase
  def test_latest
    FlickrUpdate.new.save
    # Times from the database don't have usec. Sleep so that the following
    # update is at least one second later than the previous.
    sleep 1
    FlickrUpdate.new.save
    latest = FlickrUpdate.latest

    updates = FlickrUpdate.find :all, :order => :created_at
    assert_equal updates[1].created_at, latest.created_at
    
  end

end
