module PhotosHelper

  def other_photos_path(sorted_by)
    photos_path sorted_by,
      sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+', 1
  end

  # Returns a phrase like '24 hours ago', always with a single time unit,
  # carefully adjusted to match what Flickr shows on comments on photos.
  def ago(time)
    now = Time.now.getutc
    time = time.getutc
    ago =
      if time > now - 1.second
        'a moment'
      elsif time > now - 1.minute
        pluralize (now - time).to_i, 'second'
      elsif time > now - 1.hour
        minutes = now.min - time.min
        if minutes < 0
          minutes += 60
        end
        pluralize minutes, 'minute'
      elsif time > now - 37.hours
        hours = now.hour - time.hour
        if hours < 0
          hours += 24
        end
        pluralize hours, 'hour'
      elsif time > now - 1.month
        days = (now + 12.hours).yday - time.yday
        if days < 0
          days += 365
        end
        days >= 10 ? "#{(days + 4) / 7} weeks" : "#{days} days"
      else
        months = now.month - time.month + 12 * (now.year - time.year)
        pluralize months, 'month'
      end
    ago << ' ago'
    ago
  end

end
