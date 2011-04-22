class PhotosController < ApplicationController
  include Color

  caches_page :index
  def index
    @photo_count = Photo.count
    @photos = Photo.all_sorted_and_paginated params[:sorted_by], params[:order],
      params[:page], 30
  end

  caches_page :map
  def map
    @json = posts_for_map.to_json
  end

  # TODO Dave test
  def map_json
    render :json => posts_for_map
  end

  def posts_for_map
    photos = photos_within bounds
    photos_count = photos.length # Call length before first and last so the latter don't issue their own queries
    first_dateadded = photos.first.dateadded
    last_dateadded = photos.last.dateadded
    photos = thin photos, 1000, 20, 5
    photos.each { |photo| add_display_attributes photo, first_dateadded, last_dateadded }
    { :partial => (photos_count != photos.length), :photos => photos.as_json(:only => [ :id, :latitude, :longitude, :color, :symbol ]) }
  end
  private :posts_for_map

  def bounds
    if params[:sw]
      sw = params[:sw].split(',').map &:to_f
      ne = params[:ne].split(',').map &:to_f
      Bounds.new :sw[0], ne[0], sw[1], ne[1]
    end
  end
  private :bounds

  def photos_within(bounds)
    posts = Photo.where('accuracy >= 12').order('dateadded')
    if bounds
      posts = posts.where '? < latitude and latitude < ? and ? < longitude and longitude < ?',
        bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long
    end
    posts
  end
  private :photos_within

  def thin(photos, too_many, bins_per_axis, photos_per_bin)
    if photos.length <= too_many
      return photos
    end
    binnable_photos, thinned_photos = photos.partition { |photo| is_more_or_less_in_mainland_san_francisco photo }
    min_latitude, max_latitude = (binnable_photos.map &:latitude).minmax
    min_longitude, max_longitude = (binnable_photos.map &:longitude).minmax
    binned_photos = binnable_photos.group_by { |photo| bin photo, bins_per_axis, min_latitude, max_latitude, min_longitude, max_longitude }
    binned_photos.each_value do |bin|
      if bin.length > photos_per_bin
        bin = bin.sort { |a, b| b.dateadded <=> a.dateadded }
      end
      thinned_photos += bin.first photos_per_bin
    end
    thinned_photos
  end
  private :thin

  def is_more_or_less_in_mainland_san_francisco(photo)
    37.708333 < photo.latitude && photo.latitude < 37.810869 && -122.514381 < photo.longitude && photo.longitude < -122.356625
  end
  private :is_more_or_less_in_mainland_san_francisco

  def bin(photo, bins_per_axis, min_latitude, max_latitude, min_longitude, max_longitude)
    latitude_bin = ((photo.latitude - min_latitude) / (max_latitude - min_latitude) * bins_per_axis).to_i
    longitude_bin = ((photo.longitude - min_longitude) / (max_longitude - min_longitude) * bins_per_axis).to_i
    [ latitude_bin, longitude_bin ]
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
