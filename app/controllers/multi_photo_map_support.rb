module MultiPhotoMapSupport
  include MapSupport

  INITIAL_MAP_BOUNDS = Bounds.new 37.70571, 37.820904, -122.514381, -122.35714
  BINS_PER_AXIS = 20

  def bounds
    if params[:sw]
      sw = params[:sw].split(',').map &:to_f
      ne = params[:ne].split(',').map &:to_f
      Bounds.new sw[0], ne[0], sw[1], ne[1]
    else
      INITIAL_MAP_BOUNDS
    end
  end
  private :bounds

  # public only for testing
  def max_map_photos
    2000
  end

  def as_json(partial, photos)
    {
      partial: partial,
      bounds: bounds,
      photos: photos.as_json(only: [ :id, :latitude, :longitude, :color, :symbol ])
    }
  end
  private :as_json

end
