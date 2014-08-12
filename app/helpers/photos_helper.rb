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
    if time > now - 1.second
      'a moment'
    else
      value, unit =
        if time > now - 1.minute
          [(now - time).to_i, 'second']
        elsif time > now - 1.hour
          [add_if_negative(now.min - time.min, 60), 'minute']
        elsif time > now - 37.hours
          [add_if_negative(now.hour - time.hour, 24), 'hour']
        elsif time > now - 1.month
          days = add_if_negative (now + 12.hours).yday - time.yday, 365
          if days >= 10
            [(days + 4) / 7, 'week']
          else
            [days, 'day']
          end
        else
          [now.month - time.month + 12 * (now.year - time.year), 'month']
        end
      pluralize value, unit
    end + ' ago'
  end

  private def add_if_negative(value, increment)
   value < 0 ? value + increment : value
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

end
