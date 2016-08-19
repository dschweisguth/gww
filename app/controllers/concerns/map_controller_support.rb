module MapControllerSupport
  include GoogleMapsConfig

  private def add_map_data_to_page_config(map_data)
    @page_config = with_google_maps_api_key map_data
  end

  # public only for use in tests
  def with_google_maps_api_key(json_data)
    { api_key: google_maps_api_key }.merge json_data
  end

end
