require File.dirname(__FILE__) + '/../test_helper'

class FlickrUpdateTest < Test::Unit::TestCase

  def test_local_latest_update_times_1
    start = Time.now
    FlickrUpdate.new.save
    local_latest_update_times = FlickrUpdate.local_latest_update_times(1)

    assert_equal 1, local_latest_update_times.length
    assert local_latest_update_times[0].to_i - start.to_i + 28800 <= 5

  end

  def test_local_latest_update_times_2
    start = Time.now
    FlickrUpdate.new.save
    # Times from the database don't have usec. Sleep so that the following
    # update is at least one second later than the previous.
    sleep 1
    FlickrUpdate.new.save
    local_latest_update_times = FlickrUpdate.local_latest_update_times(2)

    assert_equal 2, local_latest_update_times.length
    assert local_latest_update_times[0] > local_latest_update_times[1]

  end

end
