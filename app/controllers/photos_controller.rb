require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'md5'

class PhotosController < ApplicationController
  auto_complete_for :person, :username

  def update
    # set the particulars
    flickr_url = 'http://api.flickr.com/services/rest/'
    flickr_method = 'flickr.groups.pools.getPhotos'
    flickr_credentials = FlickrCredentials.new
    gwsf_id = '32053327@N00'
    extras = 'geo,last_update'
    per_page = 500
    get_page = 1
    photo_count = 0
    user_count = 0    
    # booleans
    reached_end = false
    found_existing = false
    
    # record the time of this update
    this_update = FlickrUpdate.new
    this_update.updated_at = Time.now
    this_update.save
    
    while !reached_end && !found_existing
      # generate the api signature
      sig_raw = flickr_credentials.secret +
	  'api_key' + flickr_credentials.api_key +
          'auth_token' + flickr_credentials.auth_token +
          'extras' + extras + 'group_id' + gwsf_id + 'method' + flickr_method +
          'page' + get_page.to_s + 'per_page' + per_page.to_s
      api_sig = MD5.hexdigest(sig_raw)
      # grab the next page of photos in the pool
      #page_url =  'http://localhost:3001/flickr_groups_pools_getPhotos.xml'
      page_url =  flickr_url + '?method=' + flickr_method +
                  '&api_key=' + flickr_credentials.api_key +
		  '&auth_token=' + flickr_credentials.auth_token +
                  '&api_sig=' + api_sig + '&group_id=' + gwsf_id +
                  '&per_page=' + per_page.to_s + '&page=' + get_page.to_s +
                  '&extras=' + extras
      page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
      flickr_page = XmlSimple.xml_in(page_xml)['photos'][0]

      # step through the returned photos
      flickr_page['photo'].each do |new_photo|
        # try to get a record for this photo
        photo = Photo.find_by_flickrid(new_photo['id'])
        # if it doesn't exist, create it
        if !photo
          photo_count = photo_count + 1
          photo = Photo.new
          photo.game_status = "unfound"
        else
          # check for a guess on this photo
          guess = Guess.find_by_photo_id(photo[:id])
          if guess then photo.game_status = "found" end
        end
        photo.flickrid = new_photo['id']
        photo.secret = new_photo['secret']
        photo.server = new_photo['server']
        photo.farm = new_photo['farm']
        photo.dateadded = Time.at(new_photo['dateadded'].to_i)
        photo.lastupdate = Time.at(new_photo['lastupdate'].to_i)
        photo.seen_at = Time.now
        photo.flickr_status = "in pool"
        photo.mapped = (new_photo['latitude'] == '0') ? 'false' : 'true'

        # try and get a record for the owner of this photo
        person = Person.find_by_flickrid(new_photo['owner'])
        # if the person doesn't exist, create it
        if !person
          user_count = user_count + 1
          person = Person.new
        end
        person.flickrid = new_photo['owner']
        person.username = new_photo['ownername']
        person.flickr_status = "active"

        # save the person
        person.save
        # attach the person to the photo
        photo.person = person
        # save the photo
        photo.save
      end
      # check to see if we've reached the end
      if get_page >= flickr_page['pages'].to_i
        reached_end = :true
      end
      # up the page
      get_page = get_page + 1

    end
    # let them know we're done
    flash[:notice] =
      'created ' + photo_count.to_s + ' new photos and ' + user_count.to_s +
      ' new users. Got ' + (get_page - 1).to_s + ' pages out of ' +
      flickr_page['pages'] + '.</br>'
    redirect_to :controller => 'index', :action => 'index'
  end
    
  def unverified
    @photos = Photo.find(:all, :conditions =>
      ["seen_at < ? AND game_status in ('unfound', 'unconfirmed')",
        adj_last_update_time], :include => :person)
  end

  def unfound
    @photos = Photo.find(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :order => "lastupdate desc", :include => :person)
  end

  def treasures
    guesses = Guess.find(:all, :include => [{ :photo => :person }, :person])
    eligible_guesses = []
    guesses.each do |guess|
      elapsed = guess.guessed_at - guess.photo.dateadded
      if elapsed > 0
        eligible_guesses.push({ :guess => guess, :elapsed => elapsed })
      end
    end
    eligible_guesses.sort! { |x,y| y[:elapsed] <=> x[:elapsed] }
    @longest_guesses = eligible_guesses[0, 10]
    @longest_guesses.each do |guess|
      guess[:elapsed_pretty] = get_date_distance(guess[:guess].photo.dateadded, guess[:guess].guessed_at)
    end
    @shortest_guesses = eligible_guesses[-10, 10].reverse
    @shortest_guesses.each do |guess|
      guess[:elapsed_pretty] = get_date_distance(guess[:guess].photo.dateadded, guess[:guess].guessed_at)
    end
  end

  def get_date_distance(begin_date, end_date)
    years = end_date.year - begin_date.year
    months = end_date.month - begin_date.month
    days = end_date.day - begin_date.day
    hours = end_date.hour - begin_date.hour
    minutes = end_date.min - begin_date.min
    seconds = end_date.sec - begin_date.sec
    if seconds < 0
      seconds += 60
      minutes -= 1
    end
    if minutes < 0
      minutes += 60
      hours -= 1
    end
    if hours < 0
      hours += 24
      days -= 1
    end
    if days < 0
      days += 30
      months -= 1
    end
    if months < 0
      months += 12
      years -= 1
    end
    desc = []
    if (years > 0) then desc.push("#{years} years") end
    if (months > 0) then desc.push("#{months} months") end
    if (days > 0) then desc.push("#{days} days") end
    if (hours > 0) then desc.push("#{hours} hours") end
    if (minutes > 0) then desc.push("#{minutes} minutes") end
    if (seconds > 0) then desc.push("#{seconds} seconds") end
    desc.join(", ")
  end

  def unfound_pretty
    @lasttime = last_update_time
    @photos = Photo.find(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person,
      :order => "lastupdate desc")
  end

  def unfound_data
    @lasttime = last_update_time
    @photos = Photo.find(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :order => "lastupdate desc", :include => :person)
    render :layout => false
  end

  def show
    @photo = Photo.find(params[:id],
      :include => [:person, :revelation, { :guesses => :person }])
    @unconfirmed = Photo.find(:all, :conditions =>
      ["person_id = ? and game_status = ?", @photo[:person_id], "unconfirmed"])
    if params[:nocomment]
      @comments = Comment.find_all_by_photo_id(@photo.id)
    else
      @comments = load_comments(params, @photo)
      if @comments == nil then @comments = [] end
    end
  end

  def load_comments(params, photo)
    # delete all the previous comments associated with the photo
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
          # save it
          this_comment.save
          # add it to the array
          photo_comments.push(this_comment)
        end
      end
    end
    photo_comments
  end

  def change_game_status
    # get photo record
    photo = Photo.find(params[:id])
    # change the status
    photo[:game_status] = params[:photo][:game_status]
    # if the new status is unfound or unconfirmed...
    if photo[:game_status] == 'unfound' || photo[:game_status] == 'unconfirmed'
      # delete any guesses for this photo
      guesses = Guess.find_all_by_photo_id(params[:id])
      guesses.each do |guess|
        Guess.delete(guess[:id])
      end
      # delete any revelations for this photo
      revelation = Revelation.find_by_photo_id(photo.id)
      Revelation.delete(revelation[:id]) if revelation
    end
    # save the photo
    photo.save
    # redirect to show
    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  def add_guess
    if params[:comment].nil?
      flash[:notice] = 'Please select a comment before adding a guess.'
      redirect_to(:action => 'show', :id => params[:id], :nocomment => :true)
      return
    end

    # get photo and comment records
    photo = Photo.find(params[:id])
    owner = Person.find(photo[:person_id])
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
    
    # if the guesser and the owner are not the same person...
    if guesser != owner
      # mark the photo as found
      photo[:game_status] = "found"
      # save the photo
      photo.save
    
      # try and find a record for this guess
      guess = Guess.find_by_photo_id_and_person_id(photo[:id], guesser[:id])
      # if this guess hasn't already been recorded...
      if !guess
        # create a guess object
        guess = Guess.new
        # point it to the photo and the guesser
        guess[:photo_id] = photo[:id]
        guess[:person_id] = guesser[:id]
        # remember when this guess was added
        guess[:added_at] = Time.now
      end
      # give it the comment date
      comment_date = Time.at(comment[:commented_at].to_i)
      guess[:guessed_at] = comment_date
      # if there's no added at already, set to the same as guessed at
      guess[:added_at] = comment_date if !guess.added_at
      # and text
      guess[:guess_text] = comment[:comment_text]
      # and save it
      guess.save
      
      # delete any revelations for this photo
      revelation = Revelation.find_by_photo_id(photo.id)
      Revelation.delete(revelation[:id]) if revelation
    else
      # mark the photo as revealed
      photo[:game_status] = "revealed"
      # save the photo
      photo.save
    
      # try and find a record for this revelation
      revelation = Revelation.find_by_photo_id_and_person_id(photo.id, guesser.id)
      # if this revelation hasn't already been recorded...
      if !revelation
        # create a revelation object
        revelation = Revelation.new
        # point it to the photo and the guesser
        revelation[:photo_id] = photo[:id]
        revelation[:person_id] = guesser[:id]
      end
      # give it the comment date
      revelation[:revealed_at] = Time.at(comment[:commented_at].to_i)
      # and text
      revelation[:revelation_text] = comment[:comment_text]
      # and save it
      revelation.save
        
      # delete any guesses for this photo
      guesses = Guess.find_all_by_photo_id(photo.id)
      guesses.each do |guess|
        Guess.delete(guess[:id])
      end
    end
    redirect_to :action => 'show', :id => photo, :nocomment => :true
  end

  # reload and render the comments for the specified photo
  def reload_comments
    redirect_to :action => 'show', :id => params[:id]
  end

  def destroy
    # get the photo object
    photo = Photo.find(params[:id])

    # delete any comments for this photo
    Comment.delete_all('photo_id = ' + params[:id].to_s)

    # delete any revelations for this photo
    revelation = Revelation.find_by_photo_id(params[:id])
    Revelation.delete(revelation[:id]) if revelation

    # delete any guesses for this photo
    Guess.delete_all('photo_id = ' + params[:id].to_s)
    
    # if the owner of the photo doesn't have any other photos...
    all_photos = Photo.find_all_by_person_id(photo[:person_id])
    if all_photos.length == 1
      # delete the person
      Person.find(photo[:person_id]).destroy
    end

    # delete the photo
    Photo.find(params[:id]).destroy
    redirect_to :action => 'unverified'
  end

end
