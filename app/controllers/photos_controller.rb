class PhotosController < ApplicationController

  caches_page :index
  def index
    @photo_count = Photo.count
    @photos = Photo.all_sorted_and_paginated params[:sorted_by], params[:order],
      params[:page], 30
  end

  caches_page :map
  def map
    posts = Photo.all :joins => :guesses, :conditions => 'latitude is not null', :order => 'dateadded'
    posts.each do |post|
      post[:pin_color] = PhotosController.scaled_green posts.first.dateadded, posts.last.dateadded, post.dateadded
    end
    @json = posts.to_json;
  end

  def self.scaled_green(start_of_range, end_of_range, position)
    start_of_range = start_of_range.to_f
    end_of_range = end_of_range.to_f
    fractional_position = start_of_range == end_of_range \
      ? 1 : (position.to_f - start_of_range) / (end_of_range - start_of_range)
    intensity = (256.0 * (1 - 0.5 * fractional_position)).to_i
    intensity -= intensity % 4
    if intensity == 256
      intensity = 252
    end
    others_intensity = (224.0 * (1 - fractional_position)).to_i
    others_intensity -= others_intensity % 4
    "%02X%02X%02X" % [ others_intensity, intensity, others_intensity ]
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
