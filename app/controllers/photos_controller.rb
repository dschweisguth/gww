class PhotosController < ApplicationController
  include SinglePhotoMapSupport, MultiPhotoMapSupport

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
    photos = Photo.mapped(bounds, max_map_photos + 1)
    partial = photos.length == max_map_photos + 1
    if partial
      photos.pop
    end
    first_photo = Photo.oldest
    if first_photo
      use_inferred_geocode_if_necessary(photos)
      photos.each { |photo| prepare_for_display photo, first_photo.dateadded }
    end
    as_json partial, photos
  end

  caches_page :map_popup
  def map_popup
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

  # TODO Dave test
  # TODO Dave switch on Accept
  def search
    @terms, @sorted_by = terms
    @json = { 'terms' => @terms, 'sortedBy' => @sorted_by }.to_json
  end

  def search_data
    @photos = Photo.search *terms, params[:page]
    render :layout => false
  end

  def terms
    params[:terms] ||= [] # TODO Dave test
    terms = Hash[*params[:terms].split('/').each_with_index { |term, i| if i.even? then term.gsub! '-', '_' end }]
    if terms['game_status']
      terms['game_status'] = terms['game_status'].split(',')
    end
    sorted_by = terms.delete('sorted_by') || 'last-updated'
    [ terms, sorted_by ]
  end
  private :terms

  caches_page :show
  def show
    @photo = Photo.find params[:id]
    @comments = Comment.find_all_by_photo_id @photo
    set_config_to @photo
  end

end
