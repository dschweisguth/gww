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
    all_posts = Photo.where('accuracy >= 12').order('dateadded')
    if params[:sw]
      sw = params[:sw].split(',').map &:to_f
      ne = params[:ne].split(',').map &:to_f
      all_posts = all_posts.where('? < latitude and latitude < ? and ? < longitude and longitude < ?', sw[0], ne[0], sw[1], ne[1])
    end
    all_posts = all_posts.to_a # Force the query we'll run later anyway so first and last can use the results
    all_posts_length = all_posts.length
    posts = thin all_posts
    first_dateadded = all_posts.first.dateadded
    last_dateadded = all_posts.last.dateadded
    posts.each do |post|
      if post.game_status == 'unfound' || post.game_status == 'unconfirmed'
        post[:color] = 'FFFF00'
        post[:symbol] = '?'
      elsif post.game_status == 'found'
        post[:color] = scaled_green first_dateadded, last_dateadded, post.dateadded
        post[:symbol] = '!'
      else # revealed
        post[:color] = scaled_red first_dateadded, last_dateadded, post.dateadded
        post[:symbol] = '-'
      end
    end
    { :partial => (all_posts_length != posts.length), :photos => posts.as_json(:only => [ :id, :latitude, :longitude, :color, :symbol ]) }
  end
  private :posts_for_map

  def thin(photos)
    if photos.length <= 1000
      return photos
    end

    binnable_photos, thinned_photos = photos.partition { |photo| is_more_or_less_in_mainland_san_francisco photo }
    min_latitude, max_latitude = (binnable_photos.map &:latitude).minmax
    min_longitude, max_longitude = (binnable_photos.map &:longitude).minmax
    binned_photos = binnable_photos.group_by { |photo| bin min_latitude, max_latitude, min_longitude, max_longitude, photo }
    binned_photos.each_value do |bin|
      if bin.length > 5
        bin = bin.sort { |a, b| b.dateadded <=> a.dateadded }
      end
      thinned_photos += bin.first 5
    end
    thinned_photos
  end
  private :thin

  def is_more_or_less_in_mainland_san_francisco(photo)
    37.708333 < photo.latitude && photo.latitude < 37.810869 && -122.514381 < photo.longitude && photo.longitude < -122.356625
  end
  private :is_more_or_less_in_mainland_san_francisco

  def bin(min_latitude, max_latitude, min_longitude, max_longitude, photo)
    latitude_bin = ((photo.latitude - min_latitude) / (max_latitude - min_latitude) * 20).to_i
    longitude_bin = ((photo.longitude - min_longitude) / (max_longitude - min_longitude) * 20).to_i
    [ latitude_bin, longitude_bin ]
  end
  private :bin

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
