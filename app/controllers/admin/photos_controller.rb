class Admin::PhotosController < ApplicationController
  auto_complete_for :person, :username

  def update
    group_info = FlickrCredentials.request 'flickr.groups.getInfo'
    member_count = group_info['group'][0]['members'][0]
    update = FlickrUpdate.create! :member_count => member_count
    expire_cached_pages

    page = 1
    parsed_photos = nil
    existing_people = {}
    new_photo_count = 0
    new_person_count = 0    
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      logger.info "Getting page #{page} ..."
      photos_xml = FlickrCredentials.request 'flickr.groups.pools.getPhotos',
        'per_page' => '500', 'page' => page.to_s,
        'extras' => 'geo,last_update,views'
      parsed_photos = photos_xml['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }

      logger.info "Updating database from page #{page} ..."
      Photo.transaction do
        now = Time.now.getutc
        Photo.update_seen_at photo_flickrids, now

        people_flickrids =
          Set.new parsed_photos['photo'].map { |p| p['owner'] }
        existing_people_flickrids = people_flickrids - existing_people.keys
        Person.find_all_by_flickrid(existing_people_flickrids.to_a).each do |person|
          existing_people[person.flickrid] = person
        end

        existing_photos =
	  Photo.find_all_by_flickrid(photo_flickrids).index_by &:flickrid

        parsed_photos['photo'].each do |parsed_photo|
          person_flickrid = parsed_photo['owner']
          person = existing_people[person_flickrid]
          if ! person
            person = Person.new
            person.flickrid = person_flickrid
            existing_people[person_flickrid] = person
            new_person_count += 1
          end
          old_person_username = person.username
          person.username = parsed_photo['ownername']
          if person.id.nil? || person.username != old_person_username
            person.save!
          end

          photo_flickrid = parsed_photo['id']
          photo = existing_photos[photo_flickrid]
          if ! photo
            photo = Photo.new
            photo.flickrid = photo_flickrid
            photo.game_status = "unfound"
            photo.seen_at = now
            new_photo_count += 1
          end
          old_photo_farm = photo.farm
          photo.farm = parsed_photo['farm']
          old_photo_server = photo.server
          photo.server = parsed_photo['server']
          old_photo_secret = photo.secret
          photo.secret = parsed_photo['secret']
          old_photo_mapped = photo.mapped
          photo.mapped = (parsed_photo['latitude'] == '0') ? 'false' : 'true'
          old_photo_dateadded = photo.dateadded
          photo.dateadded = Time.at(parsed_photo['dateadded'].to_i).getutc
          old_photo_lastupdate = photo.lastupdate
          photo.lastupdate = Time.at(parsed_photo['lastupdate'].to_i).getutc
          old_photo_views = photo.views
          photo.views = parsed_photo['views'].to_i
          photo.person = person
          if photo.id.nil? ||
            old_photo_farm != photo.farm ||
            old_photo_server != photo.server ||
            old_photo_secret != photo.secret ||
            old_photo_mapped != photo.mapped ||
            old_photo_dateadded != photo.dateadded ||
            old_photo_lastupdate != photo.lastupdate ||
            old_photo_views != photo.views
            photo.save!
          end

        end

        page += 1
      end
    end

    update.completed_at = Time.now.getutc
    update.save!
    expire_cached_pages

    flash[:notice] = "Created #{new_photo_count} new photos and " +
      "#{new_person_count} new users. Got #{page - 1} pages out of " +
      "#{parsed_photos['pages']}.</br>"
    redirect_to admin_root_path

  end

  def update_statistics
    Photo.update_statistics
    expire_cached_pages
    flash[:notice] = 'Updated statistics.</br>'
    redirect_to admin_root_path
  end

  caches_page :unfound
  def unfound
    @photos = Photo.unfound_or_unconfirmed
  end

  caches_page :inaccessible
  def inaccessible
    @photos = Photo.all \
      :conditions =>
        [ "seen_at < ? AND game_status in ('unfound', 'unconfirmed')",
          FlickrUpdate.latest.created_at ],
      :include => :person, :order => "lastupdate desc"
  end

  caches_page :multipoint
  def multipoint
    @photos = Photo.multipoint
  end

  #noinspection RailsParamDefResolve
  def edit
    @photo = Photo.find params[:id],
      :include => [ :person, :revelation, { :guesses => :person } ]
    if params[:nocomment]
      @comments = Comment.find_all_by_photo_id(@photo)
    else
      @comments = @photo.load_comments
      expire_cached_pages
    end
  end

  def change_game_status
    Photo.change_game_status params[:id], params[:commit]
    expire_cached_pages
    redirect_to :action => 'edit', :id => params[:id], :nocomment => 'true'
  end

  def add_guess
    photo_id = params[:id]
    comment_hash = params[:comment]

    if comment_hash.nil?
      flash[:notice] =
        'Please select a comment before adding or removing a guess.'
      redirect_to :action => 'edit', :id => photo_id, :nocomment => 'true'
      return
    end

    comment_id = comment_hash[:id]
    username = params[:person][:username]

    if params[:commit] == 'Add this guess or revelation'
      Photo.transaction do
        photo = Photo.find photo_id, :include => [ :person, :revelation ]
        comment = Comment.find comment_id

        if username != ''
          guesser = Person.find_by_username username
          guesser_flickrid =
            Comment.find_by_username(username).flickrid
        else
          guesser = Person.find_by_flickrid comment[:flickrid]
          guesser_flickrid = comment.flickrid
        end
        if !guesser
          result = FlickrCredentials.request 'flickr.people.getInfo',
            'user_id' => guesser_flickrid
          guesser = Person.new
          guesser.flickrid = guesser_flickrid
          guesser.username = result['person'][0]['username'][0]
          guesser.save!
        end

        if guesser != photo.person
          photo.game_status = 'found'
          photo.save!

          guess = Guess.find_by_photo_id_and_person_id photo.id, guesser.id
          if ! guess
            guess = Guess.new
            guess.photo_id = photo.id
            guess.person_id = guesser.id
            guess.added_at = Time.now.getutc
          end
          guess.guessed_at = comment.commented_at
          guess.guess_text = comment.comment_text
          guess.save!

          Revelation.delete photo.revelation.id if photo.revelation

        else
          photo.game_status = 'revealed'
          photo.save!

          revelation = photo.revelation
          if ! revelation
            revelation = Revelation.new
            revelation.photo_id = photo.id
            revelation.added_at = Time.now.getutc
          end
          revelation.revealed_at = comment.commented_at
          revelation.revelation_text = comment.comment_text
          revelation.save!

          Guess.delete_all [ "photo_id = ?", photo.id ]

        end

      end
    else # Remove this guess or revelation
      Photo.transaction do
        photo = Photo.find photo_id, :include => [ :person, :revelation ]
        comment = Comment.find comment_id

        guesser = Person.find_by_flickrid comment[:flickrid]
        if guesser
          if guesser.id == photo.person_id
            if photo.revelation
              photo.game_status = 'unfound'
              photo.save!
              photo.revelation.destroy
            else
              flash[:notice] =
                'That comment has not been recorded as a revelation.'
            end
          else
            guess = Guess.find_by_person_id_and_guess_text guesser.id,
              comment.comment_text
            if guess
              guess_count =
                Guess.count :conditions => [ "photo_id = ?", photo.id ]
              if guess_count == 1
                photo.game_status = 'unfound'
                photo.save!
              end
              guess.destroy
            else
              flash[:notice] = 'That comment has not been recorded as a guess.'
            end
          end
        else
          flash[:notice] =
            'That comment has not been recorded as a guess or revelation.'
        end
      end
    end

    expire_cached_pages
    redirect_to :action => 'edit', :id => photo_id, :nocomment => 'true'
  end

  def reload_comments
    redirect_to :action => 'edit', :id => params[:id]
  end

  def destroy
    Photo.transaction do
      photo = Photo.find params[:id], :include => [ :revelation, :person ]
      photo.revelation.destroy if photo.revelation
      Guess.delete_all [ 'photo_id = ?', photo.id ]
      Comment.delete_all [ 'photo_id = ?', photo.id ]
      photo.destroy

      # Delete the photo's owner if they have no other photos or guesses
      if Photo.count(:conditions => [ 'person_id = ?', photo.person_id ]) == 0 &&
	Guess.count(:conditions => [ 'person_id = ?', photo.person_id ]) == 0
	photo.person.destroy
      end

    end
    expire_cached_pages
    redirect_to admin_root_path
  end

  def expire_cached_pages
    cache_dir = RAILS_ROOT + "/public/cache"
    if File.exist? cache_dir
      FileUtils.rm_r cache_dir
    end
  end
  private :expire_cached_pages

  def edit_in_gww
    in_gww 'admin/photos', 'edit'
  end

end
