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
    pathalias = parsed_person['photosurl'][0].match(/https:\/\/www.flickr.com\/photos\/([^\/]+)\//)[1]
    { username: username, pathalias: pathalias }
  end

end
