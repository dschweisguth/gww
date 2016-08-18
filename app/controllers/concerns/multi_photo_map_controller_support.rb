module MultiPhotoMapControllerSupport
  include MapControllerSupport

  MAX_MAP_PHOTOS = 2000

  def map_json
    render json: map_json_data
  end

  private def map_json_data
    with_google_maps_api_key photos: map_photos_json_data
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

end
