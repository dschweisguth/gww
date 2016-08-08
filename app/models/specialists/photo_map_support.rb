module PhotoMapSupport
  extend ActiveSupport::Concern

  attr_accessor :color, :symbol

  module ClassMethods
    def mapped(bounds, limit)
      where(
        '(accuracy >= 12 and latitude between ? and ? and longitude between ? and ?) or ' \
          '(inferred_latitude between ? and ? and inferred_longitude between ? and ?)',
          bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long,
          bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long).
        order('dateadded desc').limit(limit)
    end

    def oldest
      order('dateadded').first
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
    color, symbol =
      case game_status
        when 'unfound', 'unconfirmed'
          [Color::Yellow, '?']
        when 'found'
          [Color::Green, '!']
        else # revealed
          [Color::Red, '-']
      end
    self.color = color.scaled first_dateadded, Time.now, dateadded
    self.symbol = symbol
  end

end
