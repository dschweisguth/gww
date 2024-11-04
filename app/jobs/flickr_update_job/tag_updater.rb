module FlickrUpdateJob
  class TagUpdater
    def self.update(photo)
      begin
        tags_xml = FlickrService.instance.tags_get_list_photo photo_id: photo.flickrid
        parsed_tags = tags_xml['photo'][0]['tags'][0]['tag'] || []
        attributes_hashes = parsed_tags.map do |parsed_tag|
          { raw: parsed_tag['raw'], machine_tag: (parsed_tag['machine_tag'] == '1') }
        end
        photo.replace_tags attributes_hashes
      rescue FlickrService::FlickrRequestFailedError => e
        # Judging from how comments work, this probably happens when a photo has been removed from the group.
        Rails.logger.warn "Couldn't get tags for photo #{photo.id}, flickrid #{photo.flickrid}: FlickrService::FlickrRequestFailedError #{e.message}"
      rescue REXML::ParseException => e
        Rails.logger.warn "Couldn't get tags for photo #{photo.id}, flickrid #{photo.flickrid}: REXML::ParseException #{e.message}"
      end
    end
  end
end
