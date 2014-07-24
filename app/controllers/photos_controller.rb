class PhotosController < ApplicationController
  include SinglePhotoMapSupport, MultiPhotoMapSupport

  caches_page :index
  def index
    @photos = Photo.all_sorted_and_paginated params[:sorted_by], params[:order], params[:page], 30
  end

  caches_page :map
  def map
    @json = map_photos.to_json
  end

  def map_json
    render json: map_photos
  end

  def map_photos
    photos = Photo.mapped(bounds, max_map_photos + 1)
    partial = photos.length == max_map_photos + 1
    if partial
      photos.to_a.pop
    end
    first_photo = Photo.oldest
    if first_photo
      use_inferred_geocode_if_necessary(photos)
      photos.each { |photo| prepare_for_display photo, first_photo.dateadded }
    end
    perturb_identical_locations photos
    as_json partial, photos
  end

  caches_page :map_popup
  def map_popup
    @photo = Photo.find_with_associations params[:id].to_i
    render partial: 'photos/map/popup'
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.latest.created_at
    @photos = Photo.unfound_or_unconfirmed
    render formats: [:xml]
  end

  def search
    # TODO Dave fix nekomusume
    begin
      @terms, @sorted_by, @direction = parsed_params
    rescue ArgumentError => e
      if e.message == 'invalid date'
        redirect_to search_photos_with_terms_path params[:terms]
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
    render layout: false
  end

  private def parsed_params
    params[:terms] ||= ''
    terms = params[:terms].split('/').each_slice(2).to_h
    if terms['game-status']
      terms['game-status'] = terms['game-status'].split ','
    end
    %w(from-date to-date).each do |field|
      if terms[field]
        terms[field].gsub! '-', '/'
        begin
          Date.parse terms[field]
        rescue ArgumentError
          params[:terms].sub! %r(#{field}/[^/]+/), ''
          raise
        end
      end
    end
    if terms['from-date'] && terms['to-date'] && Date.parse(terms['from-date']) > Date.parse(terms['to-date'])
      %w(from-date to-date).each do |field|
        params[:terms].sub! %r(#{field}/[^/]+/), ''
      end
      raise ArgumentError, "invalid date"
    end
    sorted_by = terms.delete('sorted-by') || 'last-updated'
    direction = terms.delete('direction') || '-'
    [ terms, sorted_by, direction ]
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
    params[:terms] ||= ''
    terms = params[:terms].split('/').each_slice(2).to_h
    people = Person.select("people.username, count(f.id) n").joins("left join photos f on people.id = f.person_id")
    if terms['term']
      people = people.where('people.username like ?', "#{terms['term']}%")
    end
    if terms['game-status']
      people = people.where('game_status in (?)', terms['game-status'].split(','))
    end
    people = people.group("people.username").order("lower(username)")
    people.each { |person| person.label = "#{person.username} (#{person[:n]})" }
    render json: people, only: %i(username), methods: %i(label)
  end

  caches_page :show
  def show
    @photo = Photo.find params[:id].to_i
    @comments = @photo.comments
    set_config_to @photo
  end

end
