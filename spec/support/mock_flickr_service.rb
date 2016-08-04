class MockFlickrService
  def method_missing(name, *_)
    raise "#{self.class.name.sub /^Mock/, ''}.instance.#{name} is not allowed in tests"
  end

  def respond_to?(method, _include_all=false)
    %i(
      initialize
      groups_get_info
      groups_pools_get_photos
      people_get_info
      photos_get_favorites
      photos_get_info
      photos_comments_get_list
      photos_geo_get_location
      tags_get_list_photo
      request
      seconds_to_wait
    ).include? method
  end

end
