class PhotosController < ApplicationController
  include MapSupport

  caches_page :index
  def index
    @photo_count = Photo.count
    @photos = Photo.all_sorted_and_paginated params[:sorted_by], params[:order], params[:page], 30
  end

  caches_page :map
  def map
    @json = map_photos.to_json
  end

  def map_json
    render :json => map_photos
  end

  def map_photos
    photos = Photo.mapped(bounds, max_map_photos + 1).to_a
    partial = photos.length == max_map_photos + 1
    if (partial)
      photos.pop
    end
    first_photo = Photo.oldest
    if first_photo
      use_inferred_geocode_if_necessary(photos)
      photos.each { |photo| prepare_for_display photo, first_photo.dateadded }
    end
    photos_as_json partial, photos
  end

  caches_page :map_popup
  def map_popup
    #noinspection RailsParamDefResolve
    @photo = Photo.includes(:person, { :guesses => :person }, :revelation).find params[:id]
    render :partial => 'photos/map/popup'
  end

  caches_page :unfound
  def unfound
    @photos = Photo.unfound_or_unconfirmed
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.latest.created_at
    @photos = Photo.unfound_or_unconfirmed
    render :action => 'unfound_data.xml.builder', :layout => false
  end

  caches_page :show
  def show
    #noinspection RailsParamDefResolve
    @photo = Photo.includes(:person, :revelation, { :guesses => :person }).find params[:id]
    @comments = Comment.find_all_by_photo_id @photo
    if @photo.mapped_or_automapped?
      first_photo = Photo.oldest
      use_inferred_geocode_if_necessary([@photo]) # TODO Dave *
      prepare_for_display @photo, first_photo.dateadded
      @json = @photo.to_json :only => [:id, :latitude, :longitude, :color, :symbol]
    else
      @json = '{}'
    end
  end

end
