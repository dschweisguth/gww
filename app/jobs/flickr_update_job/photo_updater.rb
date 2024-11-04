module FlickrUpdateJob
  class PhotoUpdater
    def self.update_all
      page = 1
      parsed_photos = nil
      new_photo_count = 0
      new_person_count = 0
      while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
        Rails.logger.info "Getting page #{page} ..."
        # Note date_taken and path_alias here but datetaken and pathalias in the result
        photos_xml = FlickrService.instance.groups_pools_get_photos group_id: FlickrService::GROUP_ID,
          per_page: 500, page: page, extras: 'description,date_taken,geo,ispro,last_update,path_alias,views'
        parsed_photos = photos_xml['photos'][0]
        Rails.logger.info "Updating database from page #{page} ..."
        now = Time.now.getutc
        parsed_photos['photo']&.each do |parsed_photo| # &. prevents crashes when pages is incorrectly large
          person, created = find_or_create_person_from parsed_photo
          new_person_count += created
          created = create_or_update_photo_from parsed_photo, person, now
          new_photo_count += created
        end
        page += 1
      end
      return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
    end

    private_class_method def self.find_or_create_person_from(parsed_photo)
      flickrid = parsed_photo['owner']
      person = Person.find_by_flickrid flickrid
      people_created =
        if person
          # For performance, assume that an existing person has already been updated by PersonUpdater.
          0
        else
          person = Person.create!(
            flickrid: flickrid,
            username: parsed_photo['ownername'],
            pathalias: parsed_photo['pathalias'] == '' ? flickrid : parsed_photo['pathalias'],
            ispro: parsed_photo['ispro'] == '1',
            photos_count: 0 # TODO Dave this results in this attribute being incorrect until the next update
          )
          1
        end
      return person, people_created
    end

    private_class_method def self.create_or_update_photo_from(parsed_photo, person, now)
      photo = FlickrUpdatePhoto.find_by_flickrid parsed_photo['id']
      if photo
        update_photo_from(parsed_photo, now, photo)
        0
      else
        create_photo_from(parsed_photo, person, now)
        1
      end
    end

    private_class_method def self.create_photo_from(parsed_photo, person, now)
      attributes = {
        person_id: person.id,
        flickrid: parsed_photo['id'],
        dateadded: Time.at(parsed_photo['dateadded'].to_i).getutc,
        game_status: 'unfound',
        seen_at: now,
        views: parsed_photo['views'].to_i
      }
      add_full_attributes_from(parsed_photo, attributes)
      attributes[:faves] = fave_count(parsed_photo['id']) || 0

      photo = FlickrUpdatePhoto.create! attributes

      update_comments photo
      update_tags photo
    end

    private_class_method def self.update_photo_from(parsed_photo, now, photo)
      photo_needs_full_update = photo.lastupdate != lastupdate(parsed_photo['lastupdate'])
      views = parsed_photo['views'].to_i

      attributes = { seen_at: now, views: views }
      if photo_needs_full_update
        add_full_attributes_from(parsed_photo, attributes)
      end

      if photo_needs_full_update || photo.views != views
        fave_count = fave_count parsed_photo['id']
        if fave_count
          attributes[:faves] = fave_count
        end
      end

      photo.update! attributes

      if photo_needs_full_update
        update_comments photo
        update_tags photo
      end
    end

    private_class_method def self.add_full_attributes_from(parsed_photo, attributes)
      attributes.merge!(
        farm: parsed_photo['farm'],
        server: parsed_photo['server'],
        secret: parsed_photo['secret'],
        title: parsed_photo['title'],
        description: to_string_or_nil(parsed_photo['description']),
        datetaken: datetaken(parsed_photo['datetaken']),
        lastupdate: lastupdate(parsed_photo['lastupdate']),
        latitude: to_float_or_nil(parsed_photo['latitude']),
        longitude: to_float_or_nil(parsed_photo['longitude']),
        accuracy: to_integer_or_nil(parsed_photo['accuracy'])
      )
    end

    # create_or_update_photo_from updates views and faves if lastupdate or views have changed.
    # This method only does so if lastupdate has changed. It's unclear whether this is because
    # lastupdate from flickr.groups.pools.getPhotos does not reflect views but that from
    # flickr.photos.getInfo does, or whether it's just an oversight. It doesn't matter much,
    # since this method is only used before an admin edits a photo, and the other method runs
    # nightly.
    def self.update(photo)
      photo.person.update! PersonUpdater.attributes(photo.person.flickrid)

      parsed_photo = FlickrService.instance.photos_get_info(photo_id: photo.flickrid)['photo'].first
      lastupdate = lastupdate(parsed_photo['dates'][0]['lastupdate'])
      photo_needs_full_update = photo.lastupdate != lastupdate

      attributes = { seen_at: Time.now }
      if photo_needs_full_update
        latitude, longitude, accuracy = location photo
        attributes.merge!(
          farm: parsed_photo['farm'],
          server: parsed_photo['server'],
          secret: parsed_photo['secret'],
          title: to_string_or_nil(parsed_photo['title']),
          description: to_string_or_nil(parsed_photo['description']),
          views: parsed_photo['views'].to_i,
          datetaken: datetaken(parsed_photo['dates'][0]['taken']),
          lastupdate: lastupdate,
          latitude: latitude,
          longitude: longitude,
          accuracy: accuracy
        )
        fave_count = fave_count photo.flickrid
        if fave_count
          attributes[:faves] = fave_count
        end
      end

      photo.update! attributes

      if photo_needs_full_update
        if parsed_photo['comments'].first.to_i > 0
          update_comments photo
        end

        if parsed_photo['tags'].first.any?
          update_tags photo
        end

      end
    end

    private_class_method def self.location(photo)
      begin
        location = FlickrService.instance.photos_geo_get_location(photo_id: photo.flickrid)['photo'].first['location'].first
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

    private_class_method def self.lastupdate(string)
      Time.at(string.to_i).getutc
    end

    private_class_method def self.to_float_or_nil(string)
      number = string.to_f
      number.zero? ? nil : number # Use .zero? to evade rubocop cop that claims to allow == 0 but doesn't
    end

    private_class_method def self.to_integer_or_nil(string)
      number = string.to_i
      number == 0 ? nil : number
    end

    private_class_method def self.to_string_or_nil(content)
      description = content.first
      description == {} ? nil : description
    end

    private_class_method def self.datetaken(mysql_time)
      # A few photos have times like "0000-00-00 00:00:00" or "2010-00-01 00:00:00"
      begin
        ActiveSupport::TimeZone['Pacific Time (US & Canada)'].parse(mysql_time).getutc
      rescue ArgumentError => e
        if e.message.end_with? "out of range"
          Rails.logger.debug "Ignoring invalid datetaken '#{mysql_time}'"
          nil
        else
          raise
        end
      end
    end

    def self.fave_count(flickrid)
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

    def self.update_comments(photo)
      begin
        comments_xml = FlickrService.instance.photos_comments_get_list photo_id: photo.flickrid
        parsed_comments = comments_xml['comments'][0]['comment'] # nil if there are no comments and an array if there are
        if parsed_comments.nil?
          return
        end
        # Happens on photo 13744986833, on the comment supposedly containing a sad face emoji
        parsed_comments = parsed_comments.select { |c| c.key?('content') }
        if parsed_comments.any?
          attributes_hashes = parsed_comments.map do |parsed_comment|
            {
              flickrid: parsed_comment['author'],
              username: parsed_comment['authorname'],
              comment_text: parsed_comment['content'].scrub, # we got non-UTF8 text once
              commented_at: Time.at(parsed_comment['datecreate'].to_i).getutc
            }
          end
          photo.replace_comments attributes_hashes
        end
      rescue FlickrService::FlickrRequestFailedError => e
        # This happens when a photo has been removed from the group.
        Rails.logger.warn "Couldn't get comments for photo #{photo.id}, flickrid #{photo.flickrid}: FlickrService::FlickrRequestFailedError #{e.message}"
      end
    end

    def self.update_tags(photo)
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
