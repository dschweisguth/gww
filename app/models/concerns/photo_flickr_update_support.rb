module PhotoFlickrUpdateSupport
  def replace_comments(attributes_hashes)
    transaction do
      comments.clear
      attributes_hashes.each { |attributes| comments.create! attributes }
    end
  end

  def replace_tags(attributes_hashes)
    transaction do
      tags.clear
      attributes_hashes.each { |attributes| tags.create! attributes }
    end
  end

end
