class FlickrUpdater
  def self.update_everything
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    new_photo_count, new_person_count, pages_gotten, pages_available = FlickrUpdate.create_before_and_update_after do
      update_all_people
      update_all_photos
    end
    PageCache.clear
    return "Created #{new_photo_count} new photos and #{new_person_count} new users. " +
      "Got #{pages_gotten} pages out of #{pages_available}."
  end

  def self.update_all_people
    Person.where('id != 0').each do |person|
      begin
        person.update_attributes_if_necessary! Person.attrs_from_flickr(person.flickrid)
      rescue FlickrService::FlickrRequestFailedError
        # Ignore the error. We'll update again soon enough.
      end
    end
  end

  # TODO Dave count and report Flickr API calls
  # TODO Dave move delays into request method -- check how much time has passed since previous request
  def self.update_all_photos
    page = 1
    parsed_photos = nil
    existing_people = {}
    new_photo_count = 0
    new_person_count = 0
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      Rails.logger.info "Getting page #{page} ..."
      photos_xml = FlickrService.instance.groups_pools_get_photos 'group_id' => FlickrService::GROUP_ID,
        'per_page' => '500', 'page' => page.to_s, 'extras' => 'geo,last_update,path_alias,views' # Note path_alias here but pathalias in the result
      parsed_photos = photos_xml['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }

      Rails.logger.info "Updating database from page #{page} ..."

      people_flickrids = Set.new parsed_photos['photo'].map { |p| p['owner'] }
      existing_people_flickrids = people_flickrids - existing_people.keys
      Person.where(flickrid: existing_people_flickrids.to_a).each do |person|
        existing_people[person.flickrid] = person
      end

      existing_photos = Photo.where(flickrid: photo_flickrids).index_by &:flickrid

      now = Time.now.getutc

      parsed_photos['photo'].each do |parsed_photo|
        person_flickrid = parsed_photo['owner']
        person_attrs = { username: parsed_photo['ownername'], pathalias: parsed_photo['pathalias'] }
        if person_attrs[:pathalias] == ''
          person_attrs[:pathalias] = person_flickrid
        end
        person = existing_people[person_flickrid]
        if person
          person.update_attributes_if_necessary! person_attrs
        else
          person = Person.create!({ flickrid: person_flickrid }.merge person_attrs)
          existing_people[person_flickrid] = person
          new_person_count += 1
        end

        photo_flickrid = parsed_photo['id']
        photo_attrs = {
          farm: parsed_photo['farm'],
          server: parsed_photo['server'],
          secret: parsed_photo['secret'],
          latitude: to_float_or_nil(parsed_photo['latitude']),
          longitude: to_float_or_nil(parsed_photo['longitude']),
          accuracy: to_integer_or_nil(parsed_photo['accuracy']),
          lastupdate: Time.at(parsed_photo['lastupdate'].to_i).getutc,
          views: parsed_photo['views'].to_i
        }
        photo = existing_photos[photo_flickrid]
        if ! photo || photo.lastupdate != photo_attrs[:lastupdate]
          begin
            photo_attrs[:faves] = faves_from_flickr photo_flickrid
          rescue FlickrService::FlickrRequestFailedError
            # This happens when a photo is private but visible to the caller because it's posted to a group of which
            # the caller is a member. Not clear yet whether this is a bug or intended behavior.
            photo_attrs[:faves] ||= 0
          end
        end
        if photo
          photo.update_attributes_if_necessary! photo_attrs
        else
          # Set dateadded only when a photo is created, so that if a photo is added to the group,
          # removed from the group and added to the group again it retains its original dateadded.
          Photo.create!({
            person_id: person.id,
            flickrid: photo_flickrid,
            dateadded: Time.at(parsed_photo['dateadded'].to_i).getutc,
            seen_at: now,
            game_status: 'unfound'
          }.merge photo_attrs)
          new_photo_count += 1
        end

      end

      # Update seen_at after processing the entire page so that if there's an error seen_at won't have been updated for
      # photos that didn't get processed. Having photos updated except for seen_at is not so bad, so we live with that
      # chance instead of putting it all in a very long transaction.
      update_seen_at photo_flickrids, now

      page += 1
    end
    return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
  end

  # Public only for testing
  def self.update_seen_at(flickrids, time)
    Photo.where(flickrid: flickrids).update_all "seen_at = '#{time.getutc.strftime '%Y-%m-%d %H:%M:%S'}'"
  end

  private_class_method def self.to_float_or_nil(string)
    number = string.to_f
    number == 0.0 ? nil : number
  end

  private_class_method def self.to_integer_or_nil(string)
    number = string.to_i
    number == 0 ? nil : number
  end

  def self.update_photo(photo)
    # TODO Dave update the photo and poster, too

    begin
      faves = faves_from_flickr photo.flickrid
      if faves != photo.faves
        photo.update_attribute :faves, faves
      end
    rescue FlickrService::FlickrRequestFailedError
      # This happens when a photo is private but visible to the caller because it's posted to a group of which
      # the caller is a member. Not clear yet whether this is a bug or intended behavior.
    end

    begin
      comments_xml = FlickrService.instance.photos_comments_get_list 'photo_id' => photo.flickrid
      parsed_comments = comments_xml['comments'][0]['comment'] # nil if there are no comments and an array if there are
      if ! parsed_comments.blank?
        Comment.transaction do
          photo.comments.clear
          parsed_comments.each do |comment_xml|
            photo.comments.create!(
              flickrid: comment_xml['author'],
              username: comment_xml['authorname'],
              comment_text: comment_xml['content'],
              commented_at: Time.at(comment_xml['datecreate'].to_i).getutc)
          end
        end
      end
    rescue FlickrService::FlickrRequestFailedError
      # This happens when a photo has been removed from the group.
    end

  end

  def self.faves_from_flickr(photo_flickrid)
    faves_count = 0
    faves_page = 1
    parsed_faves = nil
    while parsed_faves.nil? || faves_page <= parsed_faves['pages'].to_i
      FlickrService.instance.wait_between_requests
      faves_xml = FlickrService.instance.photos_get_favorites(
          'photo_id' => photo_flickrid, 'per_page' => '50', 'page' => faves_page.to_s)
      parsed_faves = faves_xml['photo'][0]
      faves_count += parsed_faves['person'] ? parsed_faves['person'].length : 0
      faves_page += 1
    end
    faves_count
  end

end
