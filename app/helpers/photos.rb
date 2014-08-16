module Photos
  def url_for_flickr_person(person)
    "https://www.flickr.com/people/#{person.identifier}/"
  end

  def url_for_flickr_photos(person)
    "https://www.flickr.com/photos/#{person.identifier}/"
  end

  def url_for_flickr_photo(photo)
    "#{url_for_flickr_photos photo.person}#{photo.flickrid}/"
  end

  def url_for_flickr_photo_in_pool(photo)
    "#{url_for_flickr_photo photo}in/pool-guesswheresf/"
  end

  def url_for_flickr_image(photo, size = nil)
    "https://#{"farm#{photo.farm}." if photo.farm.present?}staticflickr.com/#{photo.server}/#{photo.flickrid}_#{photo.secret}#{"_#{size}" if size}.jpg"
  end

end
