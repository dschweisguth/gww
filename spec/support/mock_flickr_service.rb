class MockFlickrService
  def method_missing(name, *_)
    raise "#{self.class.name.sub /^Mock/, ''}.instance.#{name} is not allowed in tests"
  end
end
