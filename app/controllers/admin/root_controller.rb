class Admin::RootController < ApplicationController

  caches_page :index
  def index
    @latest = FlickrUpdate.latest
    @unfound_photos_count = Photo.unfound_or_unconfirmed_count
    @inaccessible_photos_count = Photo.inaccessible_count
    @multipoint_photos_count = Photo.multipoint_count
  end

  def update_from_flickr
    flash[:notice] = Updater.update
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  def calculate_statistics_and_maps
    flash[:notice] = Precalculator.calculate_statistics_and_maps
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  caches_page :bookmarklet

end
