module FlickrUpdateJob
  class FaveCounter
    def self.count(flickrid)
      begin
        parsed_faves = FlickrService.instance.photos_get_favorites photo_id: flickrid, per_page: 1
        parsed_faves['photo'][0]['total'].to_i
      rescue REXML::ParseException => e
        Rails.logger.warn "Couldn't get faves for photo flickrid #{flickrid}: FlickrService::FlickrRequestFailedError #{e.message}"
        nil
      rescue FlickrService::FlickrRequestFailedError => e
        Rails.logger.warn "Couldn't get faves for photo flickrid #{flickrid}: FlickrService::FlickrRequestFailedError #{e.message}"
        # This happens when a photo is private but visible to the caller because it's added to a group of which
        # the caller is a member. Not clear yet whether this is a bug or intended behavior.
        nil
      end
    end
  end
end
