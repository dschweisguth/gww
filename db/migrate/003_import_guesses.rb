require 'net/http'
require 'rubygems'
require 'xmlsimple'
require 'md5'

class ImportGuesses < ActiveRecord::Migration
  # bring along our own models so we don't have to worry about cached models
  # with obsolete definitions -- from Chad Fowler's "Rails Recipes", 1 ed.
  class Person < ActiveRecord::Base
    has_many :photos
    has_many :guesses
  end
  class Photo < ActiveRecord::Base
    belongs_to :person
    has_many :guesses
  end
  class Guess < ActiveRecord::Base
    belongs_to :photo
    belongs_to :person
  end
  
  def self.up
    transaction do
      # set the particulars
      flickr_url = 'http://api.flickr.com/services/rest/'
      person_method = 'flickr.people.getInfo'
      photo_method = 'flickr.photos.getInfo'
      secret = 'xxxxx' # :NOTE: replace with your API secret
      api_key = 'xxxxx' # :NOTE: replace with your API key
      auth_token = 'xxxxx' # :NOTE: replace with your auth token
      
      # open the file
      guessers = IO.readlines('doc/urls-horizontal.csv')
      # step through the rows
      guessers.each do |guess_line|
        # get rid of newline
        guess_line.chomp!
        # split the line into an array
        guess_list = guess_line.split(',')
        # shift the first argument (username) off the list
        guess_list.shift
        # the next argument is the person's flickr id
        flickr_id = guess_list.shift
        # try and get a record for this person
        guesser = Person.find_by_flickrid(flickr_id)
        # if the guesser doesn't exist...
        if !guesser
          # get information about this guesser from flickr
          # generate the api signature
          sig_raw = secret + 'api_key' + api_key + 'auth_token' + auth_token + 'method' + person_method + 'user_id' + flickr_id
          api_sig = MD5.hexdigest(sig_raw)
          page_url =  flickr_url + '?method=' + person_method +
                      '&api_key=' + api_key + '&auth_token=' + auth_token +
                      '&api_sig=' + api_sig + '&user_id=' + flickr_id
          page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
          flickr_page = XmlSimple.xml_in(page_xml)['person'][0]
          # set the guesser's details
          guesser = Person.new
          guesser.flickrid = flickr_id
          guesser.username = flickr_page['username'][0]
          guesser.iconserver = flickr_page['iconserver']
          guesser.photosurl = flickr_page['photosurl'][0]
          guesser.flickr_status = "active"
          # and save it
          guesser.save
        end
        
        # now step through the photo ids (the remaining items in the array)
        guess_list.each do |flickr_id|
          # try and get a record for this photo
          photo = Photo.find_by_flickrid(flickr_id)
          # if the photo doesn't exist...
          if !photo
            # get information about this photo from flickr
            # generate the api signature
            sig_raw = secret + 'api_key' + api_key + 'auth_token' + auth_token + 'method' + photo_method + 'photo_id' + flickr_id
            api_sig = MD5.hexdigest(sig_raw)
            page_url =  flickr_url + '?method=' + photo_method +
                        '&api_key=' + api_key + '&auth_token=' + auth_token +
                        '&api_sig=' + api_sig + '&photo_id=' + flickr_id
            # get the data and parse it
            page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
            full_flickr_page = XmlSimple.xml_in(page_xml)
            # if we didn't get an error from flickr...
            if full_flickr_page['stat'] == 'ok'
              flickr_page = full_flickr_page['photo'][0]
              # create the new photo object and fill it up
              photo = Photo.new
              photo.flickrid = flickr_id
              photo.secret = flickr_page['secret']
              photo.server = flickr_page['server']
              photo.dateadded = Time.at(flickr_page['dateuploaded'].to_i)
              photo.lastupdate = Time.at(flickr_page['dates'][0]['lastupdate'].to_i)
              photo.seen_at = Time.now
              photo.flickr_status = "not in pool"
              photo.mapped = (!flickr_page['location']) ? 'false' : 'true'
            
              # now try and get a record for the owner of this photo
              owner = Person.find_by_flickrid(flickr_page['owner'][0]['nsid'])
              # if the owner doesn't exist, create it
              if !owner
                owner = Person.new
              end
              # set the details
              owner.flickrid = flickr_page['owner'][0]['nsid']
              owner.username = flickr_page['owner'][0]['username']
              owner.flickr_status = "active"
            
              # save the owner
              owner.save
              # attach the owner to the photo
              photo.person = owner
            
            # we got an error from flickr
            else
              photo = Photo.new
              photo.flickrid = flickr_id
              photo.dateadded = Time.at(0)
              photo.lastupdate = Time.at(0)
              photo.seen_at = Time.now
              photo.flickr_status = "missing"
            end
          end
          # mark the photo as found
          photo.game_status = "found"
          # save the photo
          photo.save
          
          # try and find a record for this guess
          guess = Guess.find_by_photo_id_and_person_id(photo.id, guesser.id)
          # if this guess hasn't already been recorded...
          if !guess
            # create a guess object
            guess = Guess.new
            # point it to the photo and the guesser
            guess.photo = photo
            guess.person = guesser
            # give it a zero date for when it was guessed
            guess.guessed_at = Time.at(0)
            # and save it
            guess.save
          end
        end
      end
    end
  end

  def self.down
    raise IrreversibleMigration.new("Can't clean out this data once it's been created.")
  end
end
