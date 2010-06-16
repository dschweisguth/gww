module PhotosHelper

  def list_url(sorted_by)
    list_photos_url :sorted_by => sorted_by,
      :order => (@sorted_by == sorted_by && @order == '+' ? '-' : '+'),
      :page => 1
  end

end
