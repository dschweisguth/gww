module MapControllerSupport
  private def add_map_data_to_page_config(map_data)
    @page_config = with_google_maps_api_key map_data
  end

  # public only for use in tests
  def with_google_maps_api_key(json_data)
    { api_key: ENV.fetch('GOOGLE_MAPS_API_KEY') }.merge json_data
  end

end
