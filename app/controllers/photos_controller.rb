require 'md5'
require 'net/http'
require 'xmlsimple'

class PhotosController < ApplicationController
  auto_complete_for :person, :username

  def update
    FlickrUpdate.new.save
    
    page = 1
    parsed_photos = nil
    new_photo_count = 0
    new_user_count = 0    
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      photos_xml = photos_xml page
      parsed_photos = XmlSimple.xml_in(photos_xml)['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }
      
      now = Time.now
      Photo.update_seen_at photo_flickrids, now
      
      existing_photos = {}
      Photo.find_all_by_flickrid(photo_flickrids).each do |photo|
        existing_photos[photo.flickrid] = photo
      end

      logger.info "Updating database from page #{page} ..."
      people = {}
      parsed_photos['photo'].each do |parsed_photo|
        person_flickrid = parsed_photo['owner']
        person = people[person_flickrid]
        if ! person
          person = Person.find_by_flickrid(person_flickrid)
          people[person_flickrid] = person
        end
        person_changed = false
        if ! person
          person = Person.new
          person.flickrid = person_flickrid
          person.flickr_status = "active"
          people[person_flickrid] = person
          person_changed = true
          new_user_count += 1
        end
        ownername = parsed_photo['ownername']
        if person.username != ownername
          person.username = ownername
          person_changed = true
        end
        if person_changed
          person.save
        end

        photo_flickrid = parsed_photo['id']
        photo = existing_photos[photo_flickrid]
        photo_changed = false
        if !photo
          photo = Photo.new
          photo.flickrid = photo_flickrid
          photo.game_status = "unfound"
          photo.seen_at = now
          new_photo_count += 1
          photo_changed = true
        end
        photo_changed |= prop_changed photo, :farm, parsed_photo['farm']
        photo_changed |= prop_changed photo, :server, parsed_photo['server']
        photo_changed |= prop_changed photo, :secret, parsed_photo['secret']
        photo_changed |= prop_changed photo, :mapped,
	  (parsed_photo['latitude'] == '0') ? 'false' : 'true'
        photo_changed |= prop_changed photo, :dateadded,
	  Time.at(parsed_photo['dateadded'].to_i)
        photo_changed |= prop_changed photo, :lastupdate,
          Time.at(parsed_photo['lastupdate'].to_i)
        photo_changed |= prop_changed photo, :flickr_status, "in pool"
        photo_changed |= prop_changed photo, :person_id, person.id
        if photo_changed
          photo.save
        end

      end

      page += 1
    end

    flash[:notice] = "Created #{new_photo_count} new photos and " +
      "#{new_user_count} new users. Got #{page - 1} pages out of " +
      "#{parsed_photos['pages']}.</br>"
    redirect_to :controller => 'index', :action => 'index'

  end

  def photos_xml(page)
    logger.info "Getting page #{page} ..."
    base_url = 'http://api.flickr.com/services/rest/'
    flickr_method = 'flickr.groups.pools.getPhotos'
    flickr_credentials = FlickrCredentials.new
    gwsf_id = '32053327@N00'
    extras = 'geo,last_update'
    per_page = 500
    sig_raw = flickr_credentials.secret +
      'api_key' + flickr_credentials.api_key +
      'auth_token' + flickr_credentials.auth_token +
      'extras' + extras + 'group_id' + gwsf_id + 'method' + flickr_method +
      'page' + page.to_s + 'per_page' + per_page.to_s
    api_sig = MD5.hexdigest(sig_raw)
    page_url = base_url + '?method=' + flickr_method +
      '&api_key=' + flickr_credentials.api_key +
      '&auth_token=' + flickr_credentials.auth_token +
      '&api_sig=' + api_sig + '&group_id=' + gwsf_id +
      '&per_page=' + per_page.to_s + '&page=' + page.to_s + '&extras=' + extras
    failure_count = 0
    begin
      response = Net::HTTP.get_response URI.parse page_url
    rescue StandardError, Timeout::Error => e
      failure_count += 1
      sleep_time = 30 * (2 ** failure_count)
      warning = e.message
      if failure_count <= 3
	warning += "; sleeping #{sleep_time} seconds and retrying ..."
      end
      logger.warn warning
      if failure_count <= 3
	sleep sleep_time
	retry
      elsif
	raise
      end
    end
    response.body
  end

  def prop_changed(photo, prop, value)
    adjusted_value = (value.is_a? Time) ? adjust(value) : value
    changed = photo[prop] != adjusted_value
    if changed
      photo[prop] = value
    end
    changed
  end

  # Compensates for the fact that time comes from Flickr in UTC but is somehow
  # converted to local time when saved
  def adjust(time)
    time + Time.local(time.year, time.month, time.day, time.hour, time.min,
      time.sec).gmt_offset
  end

  def unfound
    @photos = unfound_or_unconfirmed_photos
  end

  def unverified
    @photos = Photo.find(:all,
      :conditions =>
        [ "seen_at < ? AND game_status in ('unfound', 'unconfirmed')",
          FlickrUpdate.local_latest_update_times(1)[0] ],
      :include => :person, :order => "lastupdate desc")
  end

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

  def unfound_pretty
    @lasttime = FlickrUpdate.latest_update_time
    @photos = unfound_or_unconfirmed_photos
  end

  def unfound_data
    @lasttime = FlickrUpdate.latest_update_time
    @photos = unfound_or_unconfirmed_photos
    render :layout => false
  end

  def unfound_or_unconfirmed_photos
    Photo.find(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc")
  end

  def orphaned
    @photos = Photo.find_all_by_person_id 0
  end

  def show
    @photo = Photo.find(params[:id],
      :include => [:person, { :revelation => :person }])
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
    # set the particulars
    flickr_url = 'http://api.flickr.com/services/rest/'
    flickr_method = 'flickr.photos.comments.getList'
    flickr_credentials = FlickrCredentials.new
    # generate the api signature
    sig_raw = flickr_credentials.secret + 'api_key' + flickr_credentials.api_key + 'auth_token' + flickr_credentials.auth_token + 'method' + flickr_method + 'photo_id' + photo[:flickrid]
    api_sig = MD5.hexdigest(sig_raw)
    # grab the comments
    page_url =  flickr_url + '?method=' + flickr_method +
                '&api_key=' + flickr_credentials.api_key +
		'&auth_token=' + flickr_credentials.auth_token +
                '&api_sig=' + api_sig + '&photo_id=' + photo[:flickrid]
    page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
    full_page = XmlSimple.xml_in(page_xml)
    photo_comments = []
    # if comments were returned...
    if full_page['comments']
      flickr_page = full_page['comments'][0]
      # step through the returned comments
      if flickr_page['comment']
        flickr_page['comment'].each do |new_comment|
          # create a comment object
          this_comment = Comment.new
          this_comment[:comment_text] = new_comment['content']
          this_comment[:commented_at] = Time.at(new_comment['datecreate'].to_i)
          this_comment[:username] = new_comment['authorname']
          this_comment[:userid] = new_comment['author']
          this_comment[:photo_id] = photo[:id]
          this_comment.save
          photo_comments.push(this_comment)
        end
      end
    end
    photo_comments
  end

  def change_game_status
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
    if params[:comment].nil?
      flash[:notice] = 'Please select a comment before adding a guess.'
      redirect_to(:action => 'show', :id => params[:id], :nocomment => :true)
      return
    end

    photo = Photo.find(params[:id], :include => [:person, :revelation])
    comment = Comment.find(params[:comment][:id])

    # try and get a record for the guesser
    # check for a submitted username first
    if params[:person][:username] != ''
      guesser = Person.find_by_username(params[:person][:username])
      flickr_id = Comment.find_by_username(params[:person][:username])[:userid]
    # otherwise, use the user attached to the comment
    else
      guesser = Person.find_by_flickrid(comment[:userid])
      flickr_id = comment[:userid]
    end
    
    # if the guesser doesn't exist in the database...
    if !guesser
      # get information about this guesser from flickr
      # set the particulars
      flickr_url = 'http://api.flickr.com/services/rest/'
      person_method = 'flickr.people.getInfo'
      flickr_credentials = FlickrCredentials.new
      # generate the api signature
      sig_raw = flickr_credentials.secret + 'api_key' + flickr_credentials.api_key + 'auth_token' + flickr_credentials.auth_token + 'method' + person_method + 'user_id' + flickr_id
      api_sig = MD5.hexdigest(sig_raw)
      page_url =  flickr_url + '?method=' + person_method +
                  '&api_key=' + flickr_credentials.api_key +
		  '&auth_token=' + flickr_credentials.auth_token +
                  '&api_sig=' + api_sig + '&user_id=' + flickr_id
      page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
      flickr_page = XmlSimple.xml_in(page_xml)['person'][0]
      # set the guesser's details
      guesser = Person.new
      guesser[:flickrid] = flickr_id
      guesser[:username] = flickr_page['username'][0]
      guesser[:iconserver] = flickr_page['iconserver']
      guesser[:photosurl] = flickr_page['photosurl'][0]
      guesser[:flickr_status] = "active"
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
        revelation[:person_id] = guesser[:id]
        revelation.added_at = Time.now
      end
      revelation[:revealed_at] = Time.at(comment[:commented_at].to_i)
      revelation[:revelation_text] = comment[:comment_text]
      revelation.save
        
      Guess.delete_all(["photo_id = ?", photo.id])
    end
    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  def reload_comments
    redirect_to :action => 'show', :id => params[:id]
  end

  def destroy
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
