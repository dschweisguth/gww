class Admin::RootController < ApplicationController

  caches_page :index
  def index
    @latest = FlickrUpdate.latest
    @unfound_photos_count = Photo.unfound_or_unconfirmed_count
    @inaccessible_photos_count =
      Photo.where("seen_at < ? and game_status in ('unfound', 'unconfirmed')", @latest.created_at).count
    @multipoint_photos_count = Guess.group(:photo_id).count.values.count { |count| count > 1 }
  end

  def update_all_from_flickr
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    new_photo_count, new_person_count, pages_gotten, pages_available = FlickrUpdate.create_before_and_update_after do
      Person.update_all_from_flickr
      Photo.update_all_from_flickr
    end
    PageCache.clear
    flash[:notice] = "Created #{new_photo_count} new photos and #{new_person_count} new users. " +
      "Got #{pages_gotten} pages out of #{pages_available}."
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  def update_statistics_and_maps
    Person.update_statistics
    Photo.update_statistics
    Photo.infer_geocodes
    PageCache.clear
    flash[:notice] = 'Updated statistics and maps.'
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  caches_page :bookmarklet

end
