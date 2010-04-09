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
        now = Time.now.getutc
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
          photo.dateadded = Time.at(parsed_photo['dateadded'].to_i).getutc
          old_photo_lastupdate = photo.lastupdate
          photo.lastupdate = Time.at(parsed_photo['lastupdate'].to_i).getutc
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
          FlickrUpdate.latest.created_at ],
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
    @photo = Photo.find params[:id],
      :include => [ :person, :revelation, { :guesses => :person } ]
    @unconfirmed = Photo.find(:all, :conditions =>
      ["person_id = ? and game_status = ?", @photo.person_id, "unconfirmed"])
    if params[:nocomment]
      @comments = Comment.find_all_by_photo_id @photo.id
    else
      @comments = load_comments params, @photo
    end
  end

  def load_comments(params, photo)
    comments = []
    Photo.transaction do
      Comment.delete_all('photo_id = ' + photo.id.to_s)
      parsed_xml = FlickrCredentials.request 'flickr.photos.comments.getList',
	'photo_id' => photo.flickrid
      if parsed_xml['comments']
	comments_xml = parsed_xml['comments'][0]
	if comments_xml['comment']
	  comments_xml['comment'].each do |comment_xml|
	    comment = Comment.new
	    comment.comment_text = comment_xml['content']
	    comment.commented_at =
              Time.at(comment_xml['datecreate'].to_i).getutc
	    comment.username = comment_xml['authorname']
	    comment.flickrid = comment_xml['author']
	    comment.photo_id = photo.id
	    comment.save
	    comments.push comment
	  end
	end
      end
    end
    comments
  end

  def change_game_status
    expire_cached_pages
    photo = Photo.find params[:id], :include => :revelation
    photo.game_status = params[:photo][:game_status]
    Photo.transaction do
      if photo.game_status == 'unfound' || photo.game_status == 'unconfirmed'
	Guess.delete_all [ "photo_id = ?", photo.id ]
	Revelation.delete photo.revelation.id if photo.revelation
      end
      photo.save
    end
    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  def add_guess
    expire_cached_pages

    if params[:comment].nil?
      flash[:notice] =
        'Please select a comment before adding or removing a guess.'
      redirect_to :action => 'show', :id => params[:id], :nocomment => :true
      return
    end

    photo = Photo.find params[:id], :include => [ :person, :revelation ]
    comment = Comment.find params[:comment][:id]

    Photo.transaction do
      if params[:commit] == 'Add this guess or revelation'

	if params[:person][:username] != ''
	  guesser = Person.find_by_username params[:person][:username]
	  guesser_flickrid =
	    Comment.find_by_username(params[:person][:username]).flickrid
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
	  guesser.save
	end

	if guesser != photo.person
	  photo.game_status = 'found'
	  photo.save

	  guess = Guess.find_by_photo_id_and_person_id photo.id, guesser.id
	  if ! guess
	    guess = Guess.new
	    guess.photo_id = photo.id
	    guess.person_id = guesser.id
	    guess.added_at = Time.now.getutc
	  end
	  comment_date = comment.commented_at
	  guess.guessed_at = comment_date
	  guess.added_at = comment_date if ! guess.added_at
	  guess.guess_text = comment.comment_text
	  guess.save

	  Revelation.delete photo.revelation.id if photo.revelation

	else
	  photo.game_status = 'revealed'
	  photo.save

	  revelation = photo.revelation
	  if ! revelation
	    revelation = Revelation.new
	    revelation.photo_id = photo.id
	    revelation.added_at = Time.now.getutc
	  end
	  revelation.revealed_at = comment.commented_at
	  revelation.revelation_text = comment.comment_text
	  revelation.save

	  Guess.delete_all [ "photo_id = ?", photo.id ]

	end

      else # Remove this guess or revelation
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
    end

    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  def reload_comments
    redirect_to :action => 'show', :id => params[:id]
  end

  def destroy
    expire_cached_pages

    Photo.transaction do
      photo = Photo.find params[:id], :include => [ :revelation, :person ]
      photo.revelation.destroy if photo.revelation
      Guess.delete_all [ 'photo_id = ?', photo.id ]
      Comment.delete_all [ 'photo_id = ?', photo.id ]
      photo.destroy

      # Delete the photo's owner if they have no other photos or guesses
      if Photo.count(:all,
	  :conditions => [ 'person_id = ?', photo.person_id ]) == 0 &&
	Guess.count(:all,
	  :conditions => [ 'person_id = ?', photo.person_id ]) == 0
	photo.person.destroy
      end

    end

    redirect_to :action => 'unverified'
  end

end
