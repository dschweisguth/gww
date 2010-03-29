class PhotosController < ApplicationController
  auto_complete_for :person, :username

  def update
    expire_cached_pages

    update = FlickrUpdate.new
    update.save

    page = 1
    parsed_photos = nil
    existing_people = {}
    new_photo_count = 0
    new_person_count = 0    
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      logger.info "Getting page #{page} ..."
      photos_xml = FlickrCredentials.request 'flickr.groups.pools.getPhotos',
        'per_page' => '500', 'page' => page.to_s, 'extras' => 'geo,last_update'
      parsed_photos = photos_xml['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }

      logger.info "Updating database from page #{page} ..."
      Photo.transaction do
        now = Time.now
        Photo.update_seen_at photo_flickrids, now

        people_flickrids =
          Set.new parsed_photos['photo'].map { |p| p['owner'] }
        existing_people_flickrids = people_flickrids - existing_people.keys
        Person.find_all_by_flickrid(people_flickrids.to_a).each do |person|
          existing_people[person.flickrid] = person
        end

        existing_photos = {}
        Photo.find_all_by_flickrid(photo_flickrids).each do |photo|
          existing_photos[photo.flickrid] = photo
        end

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
            person.save
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
          photo.dateadded = Time.at(parsed_photo['dateadded'].to_i)
          old_photo_lastupdate = photo.lastupdate
          photo.lastupdate = Time.at(parsed_photo['lastupdate'].to_i)
          photo.person = person
          if photo.id.nil? ||
            old_photo_farm != photo.farm ||
            old_photo_server != photo.server ||
            old_photo_secret != photo.secret ||
            old_photo_mapped != photo.mapped ||
            old_photo_dateadded != adjust(photo.dateadded) ||
            old_photo_lastupdate != adjust(photo.lastupdate)
            photo.save
          end

        end

        page += 1
      end
    end

    update.completed_at = Time.now.getutc
    update.save

    flash[:notice] = "Created #{new_photo_count} new photos and " +
      "#{new_person_count} new users. Got #{page - 1} pages out of " +
      "#{parsed_photos['pages']}.</br>"
    redirect_to :controller => 'index', :action => 'index'

  end

  # Compensates for the fact that time comes from Flickr in UTC but is somehow
  # converted to local time when set on the photo (even before it's saved)
  def adjust(time)
    time + Time.local(time.year, time.month, time.day, time.hour, time.min,
      time.sec).gmt_offset
  end

  caches_page :unfound
  def unfound
    @photos = unfound_or_unconfirmed_photos
  end

  caches_page :unverified
  def unverified
    @photos = Photo.find(:all,
      :conditions =>
        [ "seen_at < ? AND game_status in ('unfound', 'unconfirmed')",
          FlickrUpdate.local_latest_update_times(1)[0] ],
      :include => :person, :order => "lastupdate desc")
  end

  caches_page :multipoint
  def multipoint
    guesses_per_post = Guess.count(:all, :group => :photo_id)
    photo_ids = []
    guesses_per_post.each do |photo_id, count|
      if count > 1 then
        photo_ids.push photo_id
      end
    end
    @photos = Photo.find(:all,
      :conditions => "photos.id in (" + photo_ids.join(', ')+ ")",
      :include => :person, :order => "lastupdate desc")
  end

  caches_page :unfound_pretty
  def unfound_pretty
    @lasttime = FlickrUpdate.latest.created_at
    @photos = unfound_or_unconfirmed_photos
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.latest.created_at
    @photos = unfound_or_unconfirmed_photos
    render :layout => false
  end

  caches_page :unfound_or_unconfirmed_photos
  def unfound_or_unconfirmed_photos
    Photo.find(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc")
  end

  def show
    @photo = Photo.find params[:id], :include => [ :person, :revelation ]
    # Loading guesses eagerly with the photo doesn't eliminate the query, so
    # load them manually. TODO why is this necessary (and why is it not
    # necessary in people/commented_on)? Revisit after upgrading to current
    # ActiveRecord.
    @guesses = Guess.find_all_by_photo_id @photo.id, :include => :person
    @unconfirmed = Photo.find(:all, :conditions =>
      ["person_id = ? and game_status = ?", @photo.person_id, "unconfirmed"])
    if params[:nocomment]
      @comments = Comment.find_all_by_photo_id(@photo.id)
    else
      @comments = load_comments(params, @photo)
      if @comments == nil then @comments = [] end
    end
  end

  def load_comments(params, photo)
    Comment.delete_all('photo_id = ' + photo[:id].to_s)
    full_page = FlickrCredentials.request 'flickr.photos.comments.getList',
      'photo_id' => photo[:flickrid]
    photo_comments = []
    if full_page['comments']
      flickr_page = full_page['comments'][0]
      if flickr_page['comment']
        flickr_page['comment'].each do |new_comment|
          this_comment = Comment.new
          this_comment[:comment_text] = new_comment['content']
          this_comment[:commented_at] = Time.at(new_comment['datecreate'].to_i)
          this_comment[:username] = new_comment['authorname']
          this_comment[:flickrid] = new_comment['author']
          this_comment[:photo_id] = photo[:id]
          this_comment.save
          photo_comments.push(this_comment)
        end
      end
    end
    photo_comments
  end

  def change_game_status
    expire_cached_pages
    photo = Photo.find(params[:id], :include => :revelation)
    photo.game_status = params[:photo][:game_status]
    if photo.game_status == 'unfound' || photo.game_status == 'unconfirmed'
      Guess.delete_all(["photo_id = ?", photo.id])
      Revelation.delete(photo.revelation.id) if photo.revelation
    end
    photo.save
    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  def add_guess
    expire_cached_pages

    if params[:comment].nil?
      flash[:notice] =
        'Please select a comment before adding or removing a guess.'
      redirect_to(:action => 'show', :id => params[:id], :nocomment => :true)
      return
    end

    photo = Photo.find params[:id], :include => [ :person, :revelation ]
    comment = Comment.find(params[:comment][:id])

    if params[:commit] == 'Add this guess or revelation'

      # try and get a record for the guesser
      # check for a submitted username first
      if params[:person][:username] != ''
	guesser = Person.find_by_username(params[:person][:username])
	guesser_flickrid =
	  Comment.find_by_username(params[:person][:username])[:flickrid]
      # otherwise, use the user attached to the comment
      else
	guesser = Person.find_by_flickrid(comment[:flickrid])
	guesser_flickrid = comment[:flickrid]
      end

      # if the guesser doesn't exist in the database...
      if !guesser
	# get information about this guesser from flickr
	# set the particulars
	flickr_url = 'http://api.flickr.com/services/rest/'
	person_method = 'flickr.people.getInfo'
	flickr_credentials = FlickrCredentials.new
	# generate the api signature
	sig_raw = flickr_credentials.secret + 'api_key' + flickr_credentials.api_key + 'auth_token' + flickr_credentials.auth_token + 'method' + person_method + 'user_id' + guesser_flickrid
	api_sig = MD5.hexdigest(sig_raw)
	page_url =  flickr_url + '?method=' + person_method +
		    '&api_key=' + flickr_credentials.api_key +
		    '&auth_token=' + flickr_credentials.auth_token +
		    '&api_sig=' + api_sig + '&user_id=' + guesser_flickrid
	page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
	flickr_page = XmlSimple.xml_in(page_xml)['person'][0]
	# set the guesser's details
	guesser = Person.new
	guesser[:flickrid] = guesser_flickrid
	guesser[:username] = flickr_page['username'][0]
	# and save it
	guesser.save
      end

      if guesser != photo.person
	photo[:game_status] = "found"
	photo.save

	# try and find a record for this guess
	guess = Guess.find_by_photo_id_and_person_id(photo[:id], guesser[:id])
	# if this guess hasn't already been recorded...
	if !guess
	  guess = Guess.new
	  guess[:photo_id] = photo[:id]
	  guess[:person_id] = guesser[:id]
	  guess[:added_at] = Time.now
	end
	comment_date = Time.at(comment[:commented_at].to_i)
	guess[:guessed_at] = comment_date
	guess[:added_at] = comment_date if !guess.added_at
	guess[:guess_text] = comment[:comment_text]
	guess.save

	# delete any revelations for this photo
	Revelation.delete(photo.revelation[:id]) if photo.revelation
      else
	photo[:game_status] = "revealed"
	photo.save

	# try and find a record for this revelation
	revelation = photo.revelation
	if !revelation
	  revelation = Revelation.new
	  revelation[:photo_id] = photo[:id]
	  revelation.added_at = Time.now
	end
	revelation[:revealed_at] = Time.at(comment[:commented_at].to_i)
	revelation[:revelation_text] = comment[:comment_text]
	revelation.save

	Guess.delete_all(["photo_id = ?", photo.id])
      end
    else
      guesser = Person.find_by_flickrid comment[:flickrid]
      if guesser
        if guesser.id == photo.person_id
          if photo.revelation
            photo.game_status = 'unfound'
            photo.save
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
	      photo.save
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

    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  def reload_comments
    redirect_to :action => 'show', :id => params[:id]
  end

  def destroy
    expire_cached_pages
    photo = Photo.find(params[:id], :include => [ :revelation, :person ])
    photo.revelation.destroy if photo.revelation
    Guess.delete_all(['photo_id = ?', photo.id])
    Comment.delete_all(['photo_id = ?', photo.id])
    photo.destroy

    # If the photo's owner has no guesses or other photos, delete them too
    if Photo.count(:all,
        :conditions => [ 'person_id = ?', photo.person_id ]) == 0 &&
      Guess.count(:all,
        :conditions => [ 'person_id = ?', photo.person_id ]) == 0
      photo.person.destroy
    end

    redirect_to :action => 'unverified'

  end

end
