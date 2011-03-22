module Photos
  def url_for_flickr_photo(photo)
    "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/"
  end
end
