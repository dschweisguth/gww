module Color
end

class Color::Color
  # This method quantizes its result to reduce the number of different images that a browser must retrieve.
  def self.scaled(start_of_range, end_of_range, position)
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
