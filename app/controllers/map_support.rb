module MapSupport

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

  def max_map_photos
    2000
  end

  def use_inferred_geocode_if_necessary(photos)
    photos.each do |photo|
      if !photo.latitude
        photo.latitude = photo.inferred_latitude
        photo.longitude = photo.inferred_longitude
      end
    end
  end

  def scaled_red(start_of_range, end_of_range, position)
    scaled(start_of_range, end_of_range, position, [ [ 256, 224 ], [ 192, 0 ], [ 192, 0 ]  ])
  end

  def scaled_green(start_of_range, end_of_range, position)
    scaled(start_of_range, end_of_range, position, [ [ 224, 0 ], [ 256, 128 ], [ 224, 0 ]  ])
  end

  def scaled_blue(start_of_range, end_of_range, position)
    scaled(start_of_range, end_of_range, position, [ [ 224, 0 ], [ 224, 0 ], [ 256, 256 ] ])
  end

  def scaled(start_of_range, end_of_range, position, color_ranges)
    start_of_range = start_of_range.to_f
    end_of_range = end_of_range.to_f
    fractional_position = start_of_range == end_of_range \
      ? 1 : (position.to_f - start_of_range) / (end_of_range - start_of_range)
    intensities = color_ranges.map do |color_range|
      intensity = (color_range[0] + (color_range[1] - color_range[0]) * fractional_position).to_i
      intensity -= intensity % 4
      if intensity == 256
        intensity = 252
      end
      intensity
    end
    "%02X%02X%02X" % intensities
  end
  private :scaled

  def as_json(partial, photos)
    {
      :partial => partial,
      :bounds => bounds,
      :photos => photos.as_json(:only => [ :id, :latitude, :longitude, :color, :symbol ])
    }
  end

end
