class IndexController < ApplicationController
  def index
    @latest_update_time = FlickrUpdate.latest_update_time
    @unfound_photos_count = Photo.count(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')")
    @unverified_photos_count = Photo.count(:all,
      :conditions =>
        [ "seen_at < ? and game_status in ('unfound', 'unconfirmed')",
          FlickrUpdate.local_latest_update_times(1)[0] ])
    @multipoint_photos_count = multipoint_photos_count
  end

  def multipoint_photos_count
    guesses_per_post = Guess.count(:all, :group => :photo_id)
    multipoint_photos_count = 0
    guesses_per_post.each do |photo_id, count|
      if count > 1 then multipoint_photos_count += 1 end
    end
    multipoint_photos_count
  end

end
