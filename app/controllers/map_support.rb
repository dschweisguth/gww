module MapSupport

  INITIAL_MAP_BOUNDS = Bounds.new 37.70571, 37.820904, -122.514381, -122.35714

  def get_bounds
    if params[:sw]
      sw = params[:sw].split(',').map &:to_f
      ne = params[:ne].split(',').map &:to_f
      Bounds.new sw[0], ne[0], sw[1], ne[1]
    else
      INITIAL_MAP_BOUNDS
    end
  end

  def thin(photos, bounds, bins_per_axis)
    if photos.length <= too_many
      return photos
    end
    binned_photos = photos.group_by { |photo| bin photo, bounds, bins_per_axis }
    thinned_photos = []
    binned_photos.each_value do |bin|
      if bin.length > photos_per_bin
        bin = bin.sort { |a, b| b.dateadded <=> a.dateadded }.first photos_per_bin
      end
      thinned_photos += bin
    end
    thinned_photos
  end

  def too_many
    1000
  end

  def photos_per_bin
    6
  end

  def bin(photo, bounds, bins_per_axis)
    [ ((photo.latitude - bounds.min_lat) / (bounds.max_lat - bounds.min_lat) * bins_per_axis).to_i,
      ((photo.longitude - bounds.min_long) / (bounds.max_long - bounds.min_long) * bins_per_axis).to_i ]
  end
  private :bin

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

  def as_json(partial, bounds, photos)
    {
      :partial => partial,
      :bounds => bounds,
      :photos => photos.as_json(:only => [ :id, :latitude, :longitude, :color, :symbol ])
    }
  end

end
