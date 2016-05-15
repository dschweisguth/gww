class PhotosController < ApplicationController
  include MultiPhotoMapControllerSupport

  caches_page :index
  def index
    @photos = Photo.all_sorted_and_paginated params[:sorted_by], params[:order], params[:page], 30
  end

  caches_page :map
  def map
    @json = Photo.all_for_map(bounds, MAX_MAP_PHOTOS).to_json
  end

  def map_json
    render json: Photo.all_for_map(bounds, MAX_MAP_PHOTOS)
  end

  caches_page :map_popup
  def map_popup
    @photo = Photo.find_with_associations params[:id].to_i
    render partial: 'photos/map/popup'
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.maximum :created_at
    @photos = Photo.unfound_or_unconfirmed
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
      @photos = Photo.search(@search_params).to_a
      @text_terms = @search_params[:text] || []
      @display_fully = @text_terms.any? || @search_params[:did] == 'activity'
      render layout: false
    rescue SearchDataParamsParser::NonCanonicalSegmentsError => e
      redirect_to search_photos_data_path(e.canonical_segments)
    end
  end

  caches_page :autocomplete_usernames
  def autocomplete_usernames
    terms = (params[:terms] || '').split('/').each_slice(2).to_h
    people = Person.all_for_autocomplete terms['term'], terms['game-status']&.split(',')
    render json: people, only: %i(username), methods: %i(label)
  end

  caches_page :show
  def show
    @photo = Photo.find params[:id].to_i
    @comments = @photo.comments
    @json = @photo.to_map_json
  end

end
