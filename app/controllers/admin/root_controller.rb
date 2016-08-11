class Admin::RootController < ApplicationController
  caches_page :index
  def index
    @latest = FlickrUpdate.latest
    @unfound_photos_count = AdminRootPhoto.unfound_or_unconfirmed_count
    @inaccessible_photos_count = AdminRootPhoto.inaccessible_count
    @multipoint_photos_count = AdminRootPhoto.multipoint_count
  end

  def update_from_flickr
    flash[:notice] = FlickrUpdateJob::Job.run
    redirect_to admin_root_path
  end

  def calculate_statistics_and_maps
    flash[:notice] = PrecalculatorJob::Job.run
    redirect_to admin_root_path
  end

  caches_page :bookmarklet

end
