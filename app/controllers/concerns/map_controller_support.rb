module MapControllerSupport
  include GoogleMapsConfig

  private def set_map_json_from_photo
    map_json = @photo.as_map_json
    if map_json
      page_config.merge! with_google_maps_api_key(photo: map_json)
    end
  end

  # public only for use in tests
  def with_google_maps_api_key(json_data)
    { api_key: google_maps_api_key }.merge json_data
  end

end
