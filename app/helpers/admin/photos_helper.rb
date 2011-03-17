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
