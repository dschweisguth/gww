module PhotosHelper

  def other_photos_path(sorted_by)
    #noinspection RubyResolve
    photos_path sorted_by,
      sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+', 1
  end

  # Returns a phrase like '24 hours ago', always with a single time unit,
  # carefully adjusted to match what Flickr shows on comments on photos.
  def ago(time)
    now = Time.now.getutc
    time = time.getutc
    elapsed = now - time
    value, unit, per_next_larger_unit =
      if elapsed < 1.second
        [now - time, 'usec', 1000000]
      elsif elapsed < 1.minute
        [(now - time).to_i, 'second', 60]
      elsif elapsed < 1.hour
        [now.min - time.min, 'minute', 60]
      elsif elapsed < 37.hours
        [now.hour - time.hour, 'hour', 24]
      elsif elapsed < 1.month
        [(now + 12.hours).yday - time.yday, 'day', 365]
      else
        [now.month - time.month + 12 * (now.year - time.year), 'month', 12]
      end
    if value < 0
      value += per_next_larger_unit
    end

    if unit == 'day' && value >= 10
      value = (value + 4) / 7
      unit = 'week'
    end

    if unit == 'usec'
      'a moment'
    else
      pluralize value, unit
    end + ' ago'

  end

  def highlighted(string, text_terms, other_strings_that_count=[])
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
    /(?<!<span class="matched">)\b(#{term})\b/i
  end

  def verbose_date(date)
    date.getlocal.strftime '%l:%M %p, %B %e, %Y'
  end

  def search_url_date(date)
    date.getlocal.strftime '%-m-%-d-%Y'
  end

end
