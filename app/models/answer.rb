module Answer

  def time_elapsed_between(from, to)
    formatted_age_by_period from, to, %w(years months days hours minutes seconds)
  end

  def ymd_elapsed_between(from, to)
    result = formatted_age_by_period from, to, %w(years months days)
    result.empty? ? time_elapsed_between(from, to) : result
  end

  #noinspection RubyUnusedLocalVariable
  def formatted_age_by_period(from, to, periods)
    utc_from = from.getutc
    utc_to = to.getutc
    years = utc_to.year - utc_from.year
    months = utc_to.month - utc_from.month
    days = utc_to.day - utc_from.day
    hours = utc_to.hour - utc_from.hour
    minutes = utc_to.min - utc_from.min
    seconds = utc_to.sec - utc_from.sec
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
