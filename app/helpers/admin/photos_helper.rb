#require 'action_view/helpers/text_helper'

module Admin::PhotosHelper

  def ago(time)
    now = Time.now
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
      elsif time > now - 1.day
        hours = now.hour - time.hour
        if hours < 0
          hours += 24
        end
        pluralize hours, 'hour'
      elsif time > now - 1.month
        days = now.yday - time.yday
        if days < 0
          days += 365 # not perfect
        end
        days >= 7 ? pluralize(days / 7, 'week') : pluralize(days, 'day')
      else
        months = now.month - time.month + 12 * (now.year - time.year)
        pluralize months, 'month'
      end
    ago << ' ago'
    ago
  end

  def wrap_if(condition, begin_tag, end_tag)
    result = condition ? begin_tag : ""
    result << yield
    if condition
      result << end_tag
    end
    result
  end

end
