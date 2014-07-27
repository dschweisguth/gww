module PhotoMapSupport

  def use_inferred_geocode_if_necessary
    if !latitude
      self.latitude = inferred_latitude
      self.longitude = inferred_longitude
    end
  end

  def prepare_for_map(first_dateadded)
    use_inferred_geocode_if_necessary
    color, symbol =
      if %w(unfound unconfirmed).include? game_status
        [Color::Yellow, '?']
      elsif game_status == 'found'
        [Color::Green, '!']
      else # revealed
        [Color::Red, '-']
      end
    self.color = color.scaled first_dateadded, Time.now, dateadded
    self.symbol = symbol
  end

end
