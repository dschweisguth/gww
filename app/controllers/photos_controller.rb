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
    # TODO Dave fix nekomusume
    begin
      @terms, @sorted_by, @direction = parsed_params
    rescue ArgumentError => e
      if ['invalid date', 'invalid search parameters', 'invalid sorted_by', 'invalid direction'].include? e.message
        # noinspection RubyResolve
        redirect_to params[:terms].present? ? search_photos_with_terms_path(params[:terms]) : search_photos_path
        return
      else
        raise
      end
    end
    @json = { 'terms' => @terms, 'sortedBy' => @sorted_by, 'direction' => @direction }.to_json
  end

  def search_data
    terms, sorted_by, direction = parsed_params
    parsed_terms = parsed_terms terms
    @photos = Photo.search(parsed_terms, sorted_by, direction, params[:page]).to_a
    @text_terms = parsed_terms['text'] || []
    @display_fully = @text_terms.any? || parsed_terms['did'] == 'activity'
    @comment_selection_criterion = parsed_terms['did']
    render layout: false
  end

  private def parsed_params
    params[:terms] ||= ''
    terms = params[:terms].split('/').each_slice(2).to_h # TODO Dave fix 500 with an odd number of components

    if !['posted', 'activity', nil].include?(terms['did'])
      remove_term 'did'
      raise ArgumentError, "invalid search parameters"
    end

    if terms['did'] == 'activity'
      if !terms['done-by']
        remove_term 'done-by'
        raise ArgumentError, "invalid search parameters"
      end
      %w(text game-status).each do |field|
        if terms[field]
          remove_term field
          raise ArgumentError, "invalid search parameters"
        end
      end
    end

    if terms['game-status']
      terms['game-status'] = terms['game-status'].split ','
      if (terms['game-status'] - %w(unfound unconfirmed found revealed)).any?
        remove_term 'game-status'
        raise ArgumentError, "invalid search parameters"
      end
    end

    %w(from-date to-date).each do |field|
      if terms[field]
        terms[field].gsub! '-', '/'
        begin
          Date.parse terms[field]
        rescue ArgumentError
          remove_term field
          raise
        end
      end
    end
    if terms['from-date'] && terms['to-date'] && Date.parse(terms['from-date']) > Date.parse(terms['to-date'])
      %w(from-date to-date).each do |field|
        remove_term field
      end
      raise ArgumentError, "invalid search parameters"
    end

    sorted_by = terms.delete 'sorted-by'
    if sorted_by
      valid_orders = terms['did'] == 'activity' ? 'date-taken' : %w(date-taken date-added last-updated)
      if ! valid_orders.include?(sorted_by)
        remove_term 'sorted-by'
        raise ArgumentError, "invalid sorted_by"
      end
    else
      sorted_by = terms['did'] == 'activity' ? 'date-taken' : 'last-updated'
    end

    direction = terms.delete 'direction'
    if direction
      if ! %w(- +).include?(direction)
        remove_term 'direction'
        raise ArgumentError, "invalid direction"
      end
    else
      direction = '-'
    end

    [ terms, sorted_by, direction ]
  end

  private def remove_term(name)
    params[:terms].sub! %r(#{name}/[^/]+/), '' # matches if the term is anywhere but at the end or is at the end and there is a trailing /
    params[:terms].sub! %r((?:^|/)#{name}/[^/]+$), '' # matches if the term is at the end and there is no trailing /
  end

  private def parsed_terms(terms)
    parsed_terms = terms.dup
    if parsed_terms['text']
      parsed_terms['text'] = parsed_terms['text'].split(/\s*,\s*/).map &:split
    end
    parsed_terms
  end

  caches_page :autocomplete_usernames
  def autocomplete_usernames
    terms = (params[:terms] || '').split('/').each_slice(2).to_h
    people = Person.all_for_autocomplete terms['term'], terms['game-status'].try(:split, ',')
    render json: people, only: %i(username), methods: %i(label)
  end

  caches_page :show
  def show
    @photo = Photo.find params[:id].to_i
    @comments = @photo.comments
    @json = @photo.to_map_json
  end

end
