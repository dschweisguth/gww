require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'md5'

class UpdateController < ApplicationController

  def index
  end
  
  # mark guessed photos as found
  def mark_guessed_photos_as_found
    guesses = Guess.find_all
    guesses.each do |guess|
      photo = Photo.find(guess[:photo_id])
      photo[:game_status] = 'found'
      photo.save
    end
    # let them know we're done
    flash[:notice] =  'marked photos for ' + guesses.length.to_s + ' guesses'
    redirect_to :action => 'index'
  end
  
  # give guesses with nil added_at a date
  def set_guesses_added
    guesses = Guess.find(:all, :conditions => ["added_at = ?", 0])
    guesses.each do |guess|
      guess[:added_at] = guess[:guessed_at]
      guess.save
    end
    # let them know we're done
    flash[:notice] =  'updated ' + guesses.length.to_s + ' guesses total.'
    redirect_to :action => 'index'
  end
  
  # update the photo database
  def update_photos
    # set the particulars
    flickr_url = 'http://api.flickr.com/services/rest/'
    flickr_method = 'flickr.groups.pools.getPhotos'
    secret = 'xxxxx' # :NOTE: replace with your API secret
    api_key = 'xxxxx' # :NOTE: replace with your API key
    auth_token = 'xxxxx' # :NOTE: replace with your auth token
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
      sig_raw = secret + 'api_key' + api_key + 'auth_token' + auth_token +
                'extras' + extras + 'group_id' + gwsf_id + 'method' +
                flickr_method + 'page' + get_page.to_s + 'per_page' + per_page.to_s
      api_sig = MD5.hexdigest(sig_raw)
      # grab the next page of photos in the pool
      #page_url =  'http://localhost:3001/flickr_groups_pools_getPhotos.xml'
      page_url =  flickr_url + '?method=' + flickr_method +
                  '&api_key=' + api_key + '&auth_token=' + auth_token +
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
    flash[:notice] =  'created ' + photo_count.to_s + ' new photos and ' +
                      user_count.to_s + ' new users. Got ' + (get_page - 1).to_s +
                      ' pages out of ' + flickr_page['pages'] + '.</br>'
    redirect_to :action => 'index'
  end
    
end
