require_relative '../../spec/support/mock_flickr_service'

# Blow up if a Cucumber feature calls a method on any of the following services that actually uses an outside service
Before do
  FlickrService.class_eval { @instance = MockFlickrService.new } # TODO stub?
end
