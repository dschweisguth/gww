module PhotosHelper

  def list_path(sorted_by)
    list_photos_path sorted_by,
      sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+', 1
  end

end
