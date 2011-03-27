module Color
  def scaled_red(start_of_range, end_of_range, position)
    start_of_range = start_of_range.to_f
    end_of_range = end_of_range.to_f
    fractional_position = start_of_range == end_of_range \
      ? 1 : (position.to_f - start_of_range) / (end_of_range - start_of_range)
    intensity = (256.0 * (1 - 0.125 * fractional_position)).to_i
    intensity -= intensity % 4
    if intensity == 256
      intensity = 252
    end
    others_intensity = (192.0 * (1 - fractional_position)).to_i
    others_intensity -= others_intensity % 4
    "%02X%02X%02X" % [ intensity, others_intensity, others_intensity ]
  end

  def scaled_green(start_of_range, end_of_range, position)
    start_of_range = start_of_range.to_f
    end_of_range = end_of_range.to_f
    fractional_position = start_of_range == end_of_range \
      ? 1 : (position.to_f - start_of_range) / (end_of_range - start_of_range)
    intensity = (256.0 * (1 - 0.5 * fractional_position)).to_i
    intensity -= intensity % 4
    if intensity == 256
      intensity = 252
    end
    others_intensity = (224.0 * (1 - fractional_position)).to_i
    others_intensity -= others_intensity % 4
    "%02X%02X%02X" % [ others_intensity, intensity, others_intensity ]
  end

  def scaled_blue(start_of_range, end_of_range, position)
    start_of_range = start_of_range.to_f
    end_of_range = end_of_range.to_f
    fractional_position = start_of_range == end_of_range \
      ? 1 : (position.to_f - start_of_range) / (end_of_range - start_of_range)
    others_intensity = (224.0 * (1 - fractional_position)).to_i
    others_intensity -= others_intensity % 4
    "%02X%02XFF" % [ others_intensity, others_intensity ]
  end

end
