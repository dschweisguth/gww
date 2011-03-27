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
    posts = Photo.all :conditions => 'accuracy >= 12', :order => 'dateadded'
    first_dateadded = posts.first.dateadded
    last_dateadded = posts.last.dateadded
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
    @json = posts.to_json;
  end

  caches_page :map_popup
  #noinspection RailsParamDefResolve
  def map_popup
    @photo = Photo.find params[:id], :include => [ :person, { :guesses => :person }, :revelation ]
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
  #noinspection RailsParamDefResolve
  def show
    @photo = Photo.find params[:id],
      :include => [ :person, :revelation, { :guesses => :person } ]
    @comments = Comment.find_all_by_photo_id @photo
  end

end
