module Answer
  def time_elapsed_between(from, to)
    time_elapsed_between_in_words from, to, %w(years months days hours minutes seconds)
  end

  def ymd_elapsed_between(from, to)
    result = time_elapsed_between_in_words from, to, %w(years months days)
    result.empty? ? time_elapsed_between(from, to) : result
  end

  private

  def time_elapsed_between_in_words(from, to, units)
    time_elapsed_in_words time_elapsed_between_by_unit(from, to), units
  end

  def time_elapsed_between_by_unit(from, to)
    utc_from = from.getutc
    utc_to = to.getutc
    next_largest = nil
    [
      ['years', :year, nil],
      ['months', :month, 12],
      ['days', :day, 30],
      ['hours', :hour, 24],
      ['minutes', :min, 60],
      ['seconds', :sec, 60]
    ].
    map do |unit, method, number_in_next_largest_unit|
      value = utc_to.send(method) - utc_from.send(method)
      if value < 0
        value += number_in_next_largest_unit
        next_largest[1] -= 1
      end
      next_largest = [unit, value]
    end
  end

  def time_elapsed_in_words(time_elapsed, units)
    time_elapsed.
      select { |unit, _value| units.include? unit }.
      select { |_unit, value| value > 0 }.
      map { |unit, value| "#{value}&nbsp;#{value == 1 ? unit.singularize : unit}" }.
      join ', '
  end

end
