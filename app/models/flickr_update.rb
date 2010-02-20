class FlickrUpdate < ActiveRecord::Base

  def self.latest_update_time
     FlickrUpdate.maximum(:updated_at)
  end

  # For some reason FlickrUpdate[:updated_at] is GMT and Guess[:added_at] is
  # local time (without a time zone). The following code reduces pentime and
  # lasttime by a hardcoded subtrahend to allow comparison. The subtrahend
  # should be 28800 for PST and 25200 for PDT, which means editing the source
  # twice a year. TODO fix
  def self.local_latest_update_times(limit)
    updates = find(:all, :order => "id desc", :limit => limit);
    updates.map { |x| x[:updated_at] - 28800 }
  end

end
