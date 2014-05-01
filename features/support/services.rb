# Blow up if a Cucumber feature calls a method on any of the following services that actually uses an outside service
Before do
  FlickrService.class_eval { @instance = MockFlickrService.new } # we could just stub, but then we'd need to know that we'd run after rr.rb
end

class MockService
  def method_missing(name, *_)
    raise "#{self.class.name.sub /^Mock/, ''}.instance.#{name} is not allowed in Cucumber scenarios"
  end
end

class MockFlickrService < MockService
end
