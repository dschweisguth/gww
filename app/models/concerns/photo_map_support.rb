module PhotoMapSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def scaled_red(start_of_range, end_of_range, position)
      scaled_color start_of_range, end_of_range, position, [ [ 256, 224 ], [ 192, 0 ], [ 192, 0 ] ]
    end

    def scaled_green(start_of_range, end_of_range, position)
      scaled_color start_of_range, end_of_range, position, [ [ 224, 0 ], [ 256, 128 ], [ 224, 0 ] ]
    end

    def scaled_blue(start_of_range, end_of_range, position)
      scaled_color start_of_range, end_of_range, position, [ [ 224, 0 ], [ 224, 0 ], [ 256, 256 ] ]
    end

    private def scaled_color(start_of_range, end_of_range, position, color_ranges)
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

  def use_inferred_geocode_if_necessary
    if !latitude
      self.latitude = inferred_latitude
      self.longitude = inferred_longitude
    end
  end

  def prepare_for_map(first_dateadded)
    use_inferred_geocode_if_necessary
    now = Time.now
    if game_status == 'unfound' || game_status == 'unconfirmed'
      self.color = 'FFFF00'
      self.symbol = '?'
    elsif game_status == 'found'
      self.color = Photo.scaled_green first_dateadded, now, dateadded
      self.symbol = '!'
    else # revealed
      self.color = Photo.scaled_red first_dateadded, now, dateadded
      self.symbol = '-'
    end
  end

end
