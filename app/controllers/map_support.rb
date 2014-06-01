module MapSupport

  private def use_inferred_geocode_if_necessary(photos)
    photos.each do |photo|
      if !photo.latitude
        photo.latitude = photo.inferred_latitude
        photo.longitude = photo.inferred_longitude
      end
    end
  end

  private def prepare_for_display(photo, first_dateadded)
    now = Time.now
    if photo.game_status == 'unfound' || photo.game_status == 'unconfirmed'
      photo.color = 'FFFF00'
      photo.symbol = '?'
    elsif photo.game_status == 'found'
      photo.color = scaled_green first_dateadded, now, photo.dateadded
      photo.symbol = '!'
    else # revealed
      photo.color = scaled_red first_dateadded, now, photo.dateadded
      photo.symbol = '-'
    end
  end

  # public only for testing

  def scaled_red(start_of_range, end_of_range, position)
    scaled(start_of_range, end_of_range, position, [ [ 256, 224 ], [ 192, 0 ], [ 192, 0 ]  ])
  end

  def scaled_green(start_of_range, end_of_range, position)
    scaled(start_of_range, end_of_range, position, [ [ 224, 0 ], [ 256, 128 ], [ 224, 0 ]  ])
  end

  def scaled_blue(start_of_range, end_of_range, position)
    scaled(start_of_range, end_of_range, position, [ [ 224, 0 ], [ 224, 0 ], [ 256, 256 ] ])
  end

  private def scaled(start_of_range, end_of_range, position, color_ranges)
    start_of_range = start_of_range.to_f
    end_of_range = end_of_range.to_f
    fractional_position =
      start_of_range == end_of_range ? 1 : (position.to_f - start_of_range) / (end_of_range - start_of_range)
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

end
