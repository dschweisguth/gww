module Admin::PhotosHelper

  def wrap_if(condition, begin_tag, end_tag)
    result = condition ? begin_tag : ""
    result << yield
    if condition
      result << end_tag
    end
    result
  end

end
