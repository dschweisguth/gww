module FlickrUpdateJob
  class LocationGetter
    extend Coercions

    def self.get(flickrid)
      begin
        location = FlickrService.instance.photos_geo_get_location(photo_id: flickrid)['photo'].first['location'].first
        latitude = to_float_or_nil location['latitude']
        longitude = to_float_or_nil location['longitude']
        accuracy = to_integer_or_nil location['accuracy']
        [latitude, longitude, accuracy]
      rescue FlickrService::FlickrReturnedAnError => e
        if e.code == 2
          [nil, nil, nil]
        else
          raise
        end
      end
    end
  end
end
