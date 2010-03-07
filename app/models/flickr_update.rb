class FlickrUpdate < ActiveRecord::Base

  def self.latest
    find(:first, :order => "id desc")
  end

  # Guess.added_at seems to come from Flickr as though it were local time but
  # is stored as though it were UTC. This method returns update times adjusted
  # so that they can be compared directly with Guess.added_at. TODO address
  # this need on the Guess side.
  def self.local_latest_update_times(limit)
    updates = find(:all, :order => "id desc", :limit => limit);
    updates.map { |x| x.created_at + Time.local(x.created_at.year,
      x.created_at.month, x.created_at.day, x.created_at.hour,
      x.created_at.min, x.created_at.sec).gmt_offset }
  end

end
