module Photos
  def url_for_flickr_photo(photo)
    "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/"
  end

  def url_for_flickr_image(photo, size)
    "http://#{ "farm#{photo.farm}." if ! photo.farm.empty? }static.flickr.com/#{photo.server}/#{photo.flickrid}_#{photo.secret}#{ '_' + size if ! size.nil? }.jpg"
  end

end
