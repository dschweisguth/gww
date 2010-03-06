class IndexController < ApplicationController
  def index
    @latest = FlickrUpdate.latest
    @unfound_photos_count = Photo.count(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')")
    @unverified_photos_count = Photo.count(:all,
      :conditions =>
        [ "seen_at < ? and game_status in ('unfound', 'unconfirmed')",
          FlickrUpdate.local_latest_update_times(1)[0] ])
    @multipoint_photos_count = Guess.count(:all, :group => :photo_id).
      find_all { |photo_id, count| count > 1 }.length
  end

end
