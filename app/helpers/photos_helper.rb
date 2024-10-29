module PhotosHelper
  def other_photos_path(sorted_by)
    photos_path sorted_by, sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+', 1
  end

  # Returns a phrase like '24 hours ago', always with a single time unit,
  # carefully adjusted to match what Flickr shows on comments on photos.
  def ago_in_words(time)
    value, unit = ago(time)
    if unit == 'usec'
      'a moment'
    else
      pluralize value, unit
    end + ' ago'
  end

  private def ago(time)
    now = Time.now.getutc
    time = time.getutc
    elapsed = now - time
    value, unit =
      if elapsed < 1.second
        [now - time, 'usec']
      elsif elapsed < 1.minute
        [(now - time).to_i, 'second']
      elsif elapsed < 1.hour
        [wrap(now.min - time.min, 60), 'minute']
      elsif elapsed < 37.hours
        [wrap(now.hour - time.hour, 24), 'hour']
      elsif elapsed < 1.month
        [wrap((now + 12.hours).yday - time.yday, 365), 'day']
      else
        [wrap(now.month - time.month + 12 * (now.year - time.year), 12), 'month']
      end

    if unit == 'day' && value >= 10
      value = (value + 4) / 7
      unit = 'week'
    end

    return value, unit
  end

  private def wrap(value, per_next_larger_unit)
    value >= 0 ? value : value + per_next_larger_unit
  end

  def highlighted(string, text_terms, other_strings_that_count = [])
    # Copy the string to be highlighted, remove HTML and use that when scanning for matches
    strings_that_count = [string.gsub(/<[^>]+>/, '')] + other_strings_that_count
    substrings = string.split /(<[^<]+>)/
    text_terms.each do |group|
      if group.all? { |term| strings_that_count.any? { |string_that_counts| string_that_counts =~ contains_as_word(term) } }
        group.each do |term|
          regexp = contains_as_word term
          substrings.each_with_index do |substring, i|
            if i.even?
              substring.gsub! regexp, '<span class="matched">\\1</span>'
            end
          end
        end
      end
    end
    substrings.join
  end

  private def contains_as_word(term)
    /(?<!<span class="matched">)(?i)\b(#{term})\b/
  end

  def verbose_date(date)
    date.getlocal.strftime '%l:%M %p, %B %e, %Y'
  end

  def search_url_date(date)
    date.getlocal.strftime '%-m-%-d-%Y'
  end

end
