class IndexController < ApplicationController
  def index
    @last_update_time = last_update_time
    @unfound_photos_count = Photo.count(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')")
    @unverified_photos_count = Photo.count(:all,
      :conditions =>
        ["seen_at < ? and game_status in ('unfound', 'unconfirmed')",
          adj_last_update_time])
    @multipoint_photos_count = multipoint_photos_count
    @guesses_count = Guess.count();
    @people_count = Person.count();
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
