class BaseSearchParamsParser

  class NonCanonicalSegmentsError < StandardError
    attr_accessor :canonical_segments

    def initialize(canonical_segments)
      super # so we can see canonical_segments when the exception is printed
      @canonical_segments = canonical_segments
    end

  end

  private

  def existing_form_params(segments, *optional_param_names)
    segments ||= ''
    uri_components = segments.split '/'
    uri_params = uri_components.length.even? ? uri_components.each_slice(2).to_h : {}
    form_params = remove_invalid uri_params_to_form uri_params
    canonical_uri_params = uri_params.select { |key, _value| form_params.has_key?(key) }
    # Add params that must be in the canonical URL even if they're not in the original URL
    canonical_uri_params = add_defaults canonical_uri_params, *optional_param_names
    canonical_uri_params = remove_uri_defaults canonical_uri_params
    canonical_segments = segments_from canonical_uri_params, *optional_param_names
    if canonical_segments != segments
      raise NonCanonicalSegmentsError, canonical_segments
    end
    form_params
  end

  def uri_params_to_form(uri_params)
    uri_params = uri_params.dup
    if uri_params['game-status']
      uri_params['game-status'] = uri_params['game-status'].split ','
    end
    %w(from-date to-date).each do |field|
      if uri_params[field]
        uri_params[field] = uri_params[field].gsub '-', '/'
      end
    end
    uri_params
  end

  # Removes known parameters which have invalid values or whose presence or value conflicts with other parameters.
  # Does not bother to remove unknown parameters because those will be ignored later anyway.
  def remove_invalid(form_params)
    form_params = form_params.dup

    if ![nil, 'posted', 'activity'].include?(form_params['did'])
      form_params.delete 'did'
    end

    if form_params['did'] == 'activity'
      if !form_params.has_key?('done-by')
        form_params.delete 'did'
      end
      %w(text game-status).each do |field|
        if form_params.has_key? field
          form_params.delete field
        end
      end
    end

    if form_params.has_key?('done-by') && !Person.exists?(username: form_params['done-by'])
      form_params.delete 'done-by'
    end

    if form_params['game-status'].try(:any?) { |game_status| !%w(unfound unconfirmed found revealed).include?(game_status) }
      form_params.delete 'game-status'
    end

    %w(from-date to-date).each do |field|
      if form_params.has_key? field
        begin
          Date.parse form_params[field]
        rescue ArgumentError
          form_params.delete field
        end
      end
    end
    if form_params.has_key?('from-date') && form_params.has_key?('to-date') && Date.parse(form_params['from-date']) > Date.parse(form_params['to-date'])
      %w(from-date to-date).each do |field|
        form_params.delete field
      end
    end

    if form_params.has_key? 'sorted-by'
      valid_orders = form_params['did'] == 'activity' ? %w(date-taken) : %w(date-taken date-added last-updated)
      if !valid_orders.include?(form_params['sorted-by'])
        form_params.delete 'sorted-by'
      end
    end

    if ![nil, '-', '+'].include? form_params['direction']
      form_params.delete 'direction'
    end

    if form_params.has_key? 'page'
      begin
        Integer form_params['page']
      rescue ArgumentError
        form_params.delete 'page'
      end
    end

    form_params
  end

  def remove_uri_defaults(uri_params)
    # Don't remove page or per-page regardless of value.
    # page is required in search_data URLs and invalid in search URLs. per-page is invalid in all URLs.
    param_names_to_remove = param_names
    default_params = defaults(uri_params).select { |key, _value| param_names_to_remove.include? key }
    uri_params.reject { |key, value| value == default_params[key] }
  end

  # This method and GWW.photos.search.searchURI must agree on the canonical parameter order
  def segments_from(uri_params, *optional_param_names)
    param_names(*optional_param_names).each_with_object("") do |name, segments|
      value = uri_params[name]
      if value
        unless segments.blank?
          segments << '/'
        end
        segments << "#{name}/#{value}"
      end
    end
  end

  def add_defaults(form_params, *optional_param_names)
    param_names_to_add = param_names(*optional_param_names)
    defaults(form_params).select { |key, _value| param_names_to_add.include? key }.merge form_params
  end

  def param_names(*optional_names)
    %w(did done-by text game-status from-date to-date sorted-by direction) + optional_names
  end

  def defaults(uri_params)
    Photo.search_defaults(uri_keys_to_model uri_params).transform_keys { |key| key.to_s.gsub /_/, '-' }
  end

  def uri_keys_to_model(uri_params)
    uri_params.transform_keys { |key| key.gsub(/-/, '_').to_sym }
  end

  public def transform_keys(hash)
    hash.map { |key, value| [yield(key), value] }.to_h
  end

end
