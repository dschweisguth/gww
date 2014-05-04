class MockFlickrService
  def method_missing(name, *_)
    raise "#{self.class.name.sub /^Mock/, ''}.instance.#{name} is not allowed in tests"
  end

  # Permit this method in tests since it doesn't use an external resource
  def wait_between_requests
    FlickrService.new.wait_between_requests
  end

end
