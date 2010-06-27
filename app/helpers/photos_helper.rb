module PhotosHelper

  def list_path(sorted_by)
    list_photos_path :sorted_by => sorted_by,
      :order =>
        sorted_by == params[:sorted_by] && params[:order] == '+' ? '-' : '+',
      :page => 1
  end

end
