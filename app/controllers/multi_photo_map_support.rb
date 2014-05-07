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

  RADIUS = 0.000008

  def perturb_identical_locations(photos)
    perturbation_counts = {}
    photos.reverse_each do |photo|
      perturbation_count = perturbation_counts[[photo.latitude, photo.longitude]] || 0
      perturbation_counts[[photo.latitude, photo.longitude]] = perturbation_count + 1
      if perturbation_count > 0
        # See http://en.wikipedia.org/wiki/Involute#Examples
        angle = Math.sqrt(10 * perturbation_count) + Math::PI / 2
        cosine = Math.cos angle
        sine = Math.sin angle
        photo.longitude += RADIUS * (cosine + angle * sine)
        photo.latitude += RADIUS * (sine - angle * cosine)
      end
    end
  end

  def as_json(partial, photos)
    {
      partial: partial,
      bounds: bounds,
      photos: photos.as_json(only: [ :id, :latitude, :longitude ], methods: [ :color, :symbol ])
    }
  end
  private :as_json

end
