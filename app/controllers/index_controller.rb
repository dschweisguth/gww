class IndexController < ApplicationController
  def index
    @last_update_time = last_update_time
    @unfound_photos_count = Photo.count(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')")
    @unverified_photos_count = Photo.count(:all,
      :conditions =>
        ["seen_at < ? and game_status in ('unfound', 'unconfirmed')",
          adj_last_update_time])
    @guesses_count = Guess.count();
    @people_count = Person.count();
  end
end
