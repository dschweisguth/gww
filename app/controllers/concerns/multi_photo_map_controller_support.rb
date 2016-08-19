module MultiPhotoMapControllerSupport
  include MapControllerSupport

  def add_map_photos_to_page_config
    add_map_data_to_page_config map_json_data
  end

  def map_json
    render json: with_google_maps_api_key(map_json_data)
  end

  private def map_json_data
    { photos: map_photos_json_data }
  end

  INITIAL_MAP_BOUNDS = Bounds.new 37.70571, 37.820904, -122.514381, -122.35714

  private def bounds
    if params[:sw]
      sw = params[:sw].split(',').map &:to_f
      ne = params[:ne].split(',').map &:to_f
      Bounds.new sw[0], ne[0], sw[1], ne[1]
    else
      INITIAL_MAP_BOUNDS
    end
  end

  MAX_MAP_PHOTOS = 2000

end
