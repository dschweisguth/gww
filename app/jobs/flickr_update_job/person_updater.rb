module FlickrUpdateJob
  class PersonUpdater
    def self.update_all
      Person.where('id != 0').each do |person|
        begin
          person.update! attributes(person.flickrid)
        rescue FlickrService::FlickrRequestFailedError => e
          Rails.logger.warn "Couldn't get info for person #{person.id}, flickrid #{person.flickrid}: FlickrService::FlickrRequestFailedError #{e.message}"
          # Ignore the error. We'll update again soon enough.
        end
      end
    end

    def self.create_or_update(flickrid)
      person = Person.find_by_flickrid flickrid
      attrs = attributes flickrid
      if person
        person.update! attrs
      else
        person = Person.create!({ flickrid: flickrid }.merge attrs)
      end
      person
    end

    def self.attributes(flickrid)
      response = FlickrService.instance.people_get_info user_id: flickrid

      parsed_person = response['person'][0]
      username = parsed_person['username'][0]
      realname = parsed_person.dig 'realname', 0 # the realname tag could be missing or ...
      if realname == {} # ... empty
        realname = nil
      end
      pathalias = parsed_person['photosurl'][0].match(%r{https://www.flickr.com/photos/([^\/]+)/})[1]
      ispro = parsed_person['ispro'][0] == '1'
      photos_count = parsed_person['photos'][0]['count'][0].to_i

      { username: username, realname: realname, pathalias: pathalias, ispro: ispro, photos_count: photos_count }
    end

  end
end
