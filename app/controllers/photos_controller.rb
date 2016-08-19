class PhotosController < ApplicationController
  include MultiPhotoMapControllerSupport, SinglePhotoMapControllerSupport

  caches_page :index
  def index
    @photos = PhotosPhoto.all_sorted_and_paginated params[:sorted_by], params[:order], params[:page], 30
  end

  caches_page :map
  def map
    add_map_photos_to_page_config
  end

  private def map_photos_json_data
    PhotosPhoto.all_for_map(bounds, MAX_MAP_PHOTOS)
  end

  caches_page :map_popup
  def map_popup
    @photo = PhotosPhoto.find_with_associations params[:id].to_i
    render partial: 'photos/map/popup'
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.maximum :created_at
    @photos = PhotosPhoto.unfound_or_unconfirmed
    render formats: [:xml]
  end

  def search
    begin
      @search_params = SearchParamsParser.new.form_params params[:segments]
    rescue SearchParamsParser::NonCanonicalSegmentsError => e
      redirect_to search_photos_path(e.canonical_segments)
    end
  end

  def search_data
    begin
      @search_params = SearchDataParamsParser.new.model_params params[:segments]
      @photos = PhotosPhoto.search(@search_params).to_a
      @text_terms = @search_params[:text] || []
      @display_fully = @text_terms.any? || @search_params[:did] == 'activity'
      render layout: false
    rescue SearchDataParamsParser::NonCanonicalSegmentsError => e
      redirect_to search_photos_data_path(e.canonical_segments)
    end
  end

  caches_page :person_autocompletions
  def person_autocompletions
    terms = (params[:terms] || '').split('/').each_slice(2).to_h
    data = PhotosSearchAutocompletionsPerson.photo_search_autocompletions terms['term'], terms['game-status']&.split(',')
    render json: data
  end

  caches_page :show
  def show
    @photo = PhotosPhoto.find params[:id].to_i
    @comments = @photo.comments
    add_map_photo_to_page_config
  end

end
