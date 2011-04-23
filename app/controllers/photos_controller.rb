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
    bounds = get_bounds
    photos = Photo.within bounds
    photos_count = photos.length # Call length before first and last so the latter don't issue their own queries
    first_dateadded = photos.first.dateadded
    last_dateadded = photos.last.dateadded
    photos = thin photos, bounds, 20
    photos.each { |photo| add_display_attributes photo, first_dateadded, last_dateadded }
    {
      :partial => (photos_count != photos.length),
      :bounds => bounds,
      :photos => photos.as_json(:only => [ :id, :latitude, :longitude, :color, :symbol ])
    }
  end

  INITIAL_MAP_BOUNDS = Bounds.new 37.70571, 37.820904, -122.514381, -122.35714

  def get_bounds
    if params[:sw]
      sw = params[:sw].split(',').map &:to_f
      ne = params[:ne].split(',').map &:to_f
      Bounds.new sw[0], ne[0], sw[1], ne[1]
    else
      INITIAL_MAP_BOUNDS
    end
  end
  private :get_bounds

  def thin(photos, bounds, bins_per_axis)
    if photos.length <= too_many
      return photos
    end
    binned_photos = photos.group_by { |photo| bin photo, bounds, bins_per_axis }
    thinned_photos = []
    binned_photos.each_value do |bin|
      if bin.length > photos_per_bin
        bin = bin.sort { |a, b| b.dateadded <=> a.dateadded }.first photos_per_bin
      end
      thinned_photos += bin
    end
    thinned_photos
  end
  private :thin

  def too_many
    1000
  end

  def photos_per_bin
    6
  end

  def bin(photo, bounds, bins_per_axis)
    [ ((photo.latitude - bounds.min_lat) / (bounds.max_lat - bounds.min_lat) * bins_per_axis).to_i,
      ((photo.longitude - bounds.min_long) / (bounds.max_long - bounds.min_long) * bins_per_axis).to_i ]
  end
  private :bin

  def add_display_attributes(photo, first_dateadded, last_dateadded)
    if photo.game_status == 'unfound' || photo.game_status == 'unconfirmed'
      photo[:color] = 'FFFF00'
      photo[:symbol] = '?'
    elsif photo.game_status == 'found'
      photo[:color] = scaled_green first_dateadded, last_dateadded, photo.dateadded
      photo[:symbol] = '!'
    else # revealed
      photo[:color] = scaled_red first_dateadded, last_dateadded, photo.dateadded
      photo[:symbol] = '-'
    end
  end
  private :add_display_attributes

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
  end

end
