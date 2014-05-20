class FlickrUpdater
  def self.update_everything
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    group_info = FlickrService.instance.groups_get_info group_id: FlickrService::GROUP_ID
    member_count = group_info['group'][0]['members'][0]
    update = FlickrUpdate.create! member_count: member_count
    update_all_people
    new_photo_count, new_person_count, pages_gotten, pages_available = update_all_photos
    update.update! completed_at: Time.now.getutc
    PageCache.clear
    "Created #{new_photo_count} new photos and #{new_person_count} new users. Got #{pages_gotten} pages out of #{pages_available}."
  end

  ### People

  def self.update_all_people
    Person.where('id != 0').each do |person|
      begin
        person.update! person_attributes(person.flickrid)
      rescue FlickrService::FlickrRequestFailedError
        # Ignore the error. We'll update again soon enough.
      end
    end
  end

  def self.create_or_update_person(flickrid)
    person = Person.find_by_flickrid flickrid
    attrs = person_attributes flickrid
    if person
      person.update! attrs
    else
      person = Person.create!({ flickrid: flickrid }.merge attrs)
    end
    person
  end

  def self.person_attributes(flickrid)
    response = FlickrService.instance.people_get_info user_id: flickrid
    parsed_person = response['person'][0]
    username = parsed_person['username'][0]
    pathalias = parsed_person['photosurl'][0].match(/https:\/\/www.flickr.com\/photos\/([^\/]+)\//)[1]
    { username: username, pathalias: pathalias }
  end

  ### Photos

  # TODO Dave count and report Flickr API calls
  # TODO Dave move delays into request method -- check how much time has passed since previous request
  def self.update_all_photos
    page = 1
    parsed_photos = nil
    new_photo_count = 0
    new_person_count = 0
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      Rails.logger.info "Getting page #{page} ..."
      photos_xml = FlickrService.instance.groups_pools_get_photos group_id: FlickrService::GROUP_ID,
        per_page: 500, page: page, extras: 'geo,last_update,path_alias,views' # Note path_alias here but pathalias in the result
      parsed_photos = photos_xml['photos'][0]

      Rails.logger.info "Updating database from page #{page} ..."

      now = Time.now.getutc

      parsed_photos['photo'].each do |parsed_photo|
        # Find or create person
        person_flickrid = parsed_photo['owner']
        person_attrs = { username: parsed_photo['ownername'], pathalias: parsed_photo['pathalias'] }
        if person_attrs[:pathalias] == ''
          person_attrs[:pathalias] = person_flickrid
        end
        person = Person.find_by_flickrid person_flickrid
        # Don't bother to update an existing Person. We already did that in update_all_people.
        if ! person
          person = Person.create!({ flickrid: person_flickrid }.merge person_attrs)
          new_person_count += 1
        end

        # Update or create photo
        photo_flickrid = parsed_photo['id']
        photo_attrs = {
          farm: parsed_photo['farm'],
          server: parsed_photo['server'],
          secret: parsed_photo['secret'],
          latitude: to_float_or_nil(parsed_photo['latitude']),
          longitude: to_float_or_nil(parsed_photo['longitude']),
          accuracy: to_integer_or_nil(parsed_photo['accuracy']),
          lastupdate: Time.at(parsed_photo['lastupdate'].to_i).getutc,
          views: parsed_photo['views'].to_i,
          seen_at: now
        }
        photo = Photo.find_by_flickrid photo_flickrid
        photo_needs_update = ! photo || photo.lastupdate != photo_attrs[:lastupdate]
        if photo_needs_update
          begin
            photo_attrs[:faves] = fave_count photo_flickrid
          rescue FlickrService::FlickrRequestFailedError
            # This happens when a photo is private but visible to the caller because it's posted to a group of which
            # the caller is a member. Not clear yet whether this is a bug or intended behavior.
            if ! photo
              photo_attrs[:faves] = 0
            end
          end
        end
        if photo
          photo.update! photo_attrs
        else
          # Set dateadded only when a photo is created, so that if a photo is added to the group,
          # removed from the group and added to the group again it retains its original dateadded.
          photo = Photo.create!({
            person_id: person.id,
            flickrid: photo_flickrid,
            dateadded: Time.at(parsed_photo['dateadded'].to_i).getutc,
            game_status: 'unfound'
          }.merge photo_attrs)
          new_photo_count += 1
        end

        # Update comments
        if photo_needs_update
          update_comments photo
        end

      end

      page += 1
    end
    return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
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
      faves = fave_count photo.flickrid
      photo.update! faves: faves
    rescue FlickrService::FlickrRequestFailedError
      # This happens when a photo is private but visible to the caller because it's posted to a group of which
      # the caller is a member. Not clear yet whether this is a bug or intended behavior.
    end

    update_comments photo

  end

  def self.fave_count(photo_flickrid)
    FlickrService.instance.wait_between_requests
    faves_xml = FlickrService.instance.photos_get_favorites photo_id: photo_flickrid, per_page: 1
    faves_xml['photo'][0]['total'].to_i
  end

  def self.update_comments(photo)
    FlickrService.instance.wait_between_requests
    begin
      comments_xml = FlickrService.instance.photos_comments_get_list photo_id: photo.flickrid
      parsed_comments = comments_xml['comments'][0]['comment'] # nil if there are no comments and an array if there are
      if !parsed_comments.blank?
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

end
