class Admin::RootController < ApplicationController

  caches_page :index
  def index
    @latest = FlickrUpdate.latest
    @unfound_photos_count = Photo.unfound_or_unconfirmed_count
    @inaccessible_photos_count =
      Photo.where("seen_at < ? and game_status in ('unfound', 'unconfirmed')", @latest.created_at).count
    @multipoint_photos_count = Guess.group(:photo_id).count.values.count { |count| count > 1 }
  end

  caches_page :bookmarklet

end
