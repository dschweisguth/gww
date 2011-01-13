module Answer

  def time_elapsed_between(from, to)
    formatted_age_by_period from, to,
      %w(years months days hours minutes seconds)
  end

  def ymd_elapsed_between(from, to)
    result = formatted_age_by_period from, to, %w(years months days)
    result.empty? ? time_elapsed_between(from, to) : result
  end

  def formatted_age_by_period(from, to, periods)
    years = to.year - from.year
    months = to.month - from.month
    days = to.day - from.day
    hours = to.hour - from.hour
    minutes = to.min - from.min
    seconds = to.sec - from.sec
    if seconds < 0
      seconds += 60
      minutes -= 1
    end
    if minutes < 0
      minutes += 60
      hours -= 1
    end
    if hours < 0
      hours += 24
      days -= 1
    end
    if days < 0
      days += 30
      months -= 1
    end
    if months < 0
      months += 12
      years -= 1
    end
    time_elapsed = periods.each_with_object([]) do |name, list|
        value = eval name
	if value > 0
	  list.push "#{value}&nbsp;#{value == 1 ? name.singularize : name}"
	end
      end
    time_elapsed.join ', '
  end
  private :formatted_age_by_period

end
