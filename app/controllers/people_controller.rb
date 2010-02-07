class PeopleController < ApplicationController
  def list
    photo_counts = Photo.count(:all, :group => 'person_id')
    guess_counts = Guess.count(:all, :group => 'person_id')
    raw_people = Person.find(:all)
    @people = []
    raw_people.each do |person|
      add_person = {
        :person => person,
        :photocount =>
          photo_counts[person.id].nil? ? 0 : photo_counts[person.id],
        :guesscount => 
          guess_counts[person.id].nil? ? 0 : guess_counts[person.id],
      }
      @people.push(add_person)
    end
    @people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}
  end

  def show
    @person = Person.find(params[:id])
    
    # Map of guessers to this person's posts
    raw_photos = Photo.find_all_by_person_id(@person.id,
      :include => { :guesses => :person })
    @posted_count = raw_photos.length
    photos_by_guesser = {}
    raw_photos.each do |photo|
      photo.guesses.each do |guess|
        this_persons_guesses = photos_by_guesser[guess.person]
        if ! this_persons_guesses
          this_persons_guesses = []
          photos_by_guesser[guess.person] = this_persons_guesses
        end
        this_persons_guesses.push photo
      end
    end
    @photo_lookup = []
    photos_by_guesser.each do |person, photos|
      @photo_lookup.push({ :username => person[:username],
        :person_id => person[:id], :photos => photos,
        :count => photos.length })
    end
    @photo_lookup.sort! { |x,y| y[:count] <=> x[:count] }
    
    @unfound_photos = Photo.find(:all, :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ])
    @revealed_photos = Photo.find_all_by_person_id_and_game_status(@person.id,
      'revealed')
    
    missing_person = Person.new
    missing_person[:username] = 'unknown'
    # and one of who has posted the photos this person guessed
    raw_guesses = Guess.find_all_by_person_id(params[:id])
    @guessed_count = raw_guesses.length
    guessed_photos_by_poster = {}
    raw_guesses.each do |guess|
      guess_photo = Photo.find(guess[:photo_id])
      if guess_photo[:person_id] == 0
        poster = missing_person
      else
        poster = Person.find(guess_photo[:person_id])
      end
      if !guessed_photos_by_poster[poster]
        guessed_photos_by_poster[poster] = []
      end
      guessed_photos_by_poster[poster].push(guess_photo)
    end
    @guess_lookup = []
    guessed_photos_by_poster.each do |person, photos|
      @guess_lookup.push({:username => person[:username], :person_id => person[:id], :photos => photos, :count => photos.length})
    end
    @guess_lookup.sort! {|x,y| y[:count] <=> x[:count]}
  end

  def latest_guesses
    @person = Person.find(params[:id])
    @guesses = Guess.find_all_by_person_id(params[:id],
      :order => "guessed_at desc", :include => { :photo => :person })
  end

  def latest_posts
    @person = Person.find(params[:id])
    @photos = Photo.find_all_by_person_id(params[:id],
      :order => "dateadded desc", :include => :person)
  end
  
  def commented_on
    @person = Person.find(params[:id])
    @comments = Comment.find_all_by_userid(@person[:flickrid],
      :include => { :photo => [:person, { :guesses => :person }] })
    @photos = []
    @comments.each do |comment|
      @photos.push(comment.photo) if !@photos.include?(comment.photo)
    end
    @photos.sort! {|x,y| y[:lastupdate] <=> x[:lastupdate]}
  end
  
  def guesses
    lasttime = adj_last_update_time
    
    @last_days = []
    (1..7).each do |num|
      dates = {:begin => (lasttime - num.day).beginning_of_day, :end => (lasttime - (num - 1).day).beginning_of_day}
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_days.push({:dates => dates, :scores => scores})
    end
    
    thisweek_dates = {:begin => lasttime.beginning_of_week - 1.day, :end => lasttime}
    thisweek_scores = get_scores_from_date(thisweek_dates[:begin], nil)
    @last_weeks = [{:dates => thisweek_dates, :scores => thisweek_scores}]
    (1..5).each do |num|
      dates = {
        :begin => (lasttime - num.week).beginning_of_week - 1.day,
        :end => (lasttime - (num - 1).week).beginning_of_week - 1.day
      }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_weeks.push({:dates => dates, :scores => scores})
    end
    
    thismonth_dates = {:begin => lasttime.beginning_of_month, :end => lasttime}
    thismonth_scores = get_scores_from_date(thismonth_dates[:begin], nil)
    @last_months = [{:dates => thismonth_dates, :scores => thismonth_scores}]
    (1..5).each do |num|
      dates = {
        :begin => (lasttime - num.month).beginning_of_month,
        :end => (lasttime - (num - 1).month).beginning_of_month
      }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_months.push({:dates => dates, :scores => scores})
    end
    
    thisyear_dates = {:begin => lasttime.beginning_of_year, :end => lasttime}
    thisyear_scores = get_scores_from_date(thisyear_dates[:begin], nil)
    @last_years = [{:dates => thisyear_dates, :scores => thisyear_scores}]
    (1..2).each do |num|
      dates = {
        :begin => (lasttime - num.year).beginning_of_year,
        :end => (lasttime - (num - 1).year).beginning_of_year
      }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_years.push({:dates => dates, :scores => scores})
    end
    
    # get the date
    @report_date = lasttime
  end
  
  def get_scores_from_date(begin_date,end_date)
    if begin_date && end_date
      guesses = Guess.find(:all, :conditions => ["guessed_at > ? and guessed_at < ?", begin_date, end_date])
    elsif begin_date
      guesses = Guess.find(:all, :conditions => ["guessed_at > ?", begin_date])
    else
      guesses = Guess.find(:all)
    end
    good_guesses = []
    guessers = {}
    guesses.each do |guess|
      guessers[guess[:person_id]] ||= []
      guessers[guess[:person_id]].push(guess)
    end

    return_people = []
    guessers.each do |person_id, guesses|
      # create an object descriptive of this person
      add_person = {
        :person => Person.find(person_id),
        :guesscount => guesses.length
      }
      # step through existing entries in return_people
      found = nil
      return_people.each do |person_list|
        # if we find an item in the array with the same guess count
        if person_list[:guesscount] == add_person[:guesscount]
          # add this person to the list
          person_list[:people].push(add_person)
          found = :true
          break
        end
      end
      # if it wasn't found
      if !found
        # create a new entry
        return_people.push({:guesscount => add_person[:guesscount], :people => [add_person]})
      end
    end
    # sort & return people lists
    return_people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}
  end

  def report
    # to skip an update...
    # For some reason FlickrUpdate[:updated_at] is GMT and Guess[:added_at] is
    # local time (without a time zone). The following code reduces pentime and
    # lasttime by a hardcoded subtrahend to allow comparison. The subtrahend
    # should be 28800 for PST and 25200 for PDT, which means editing the source
    # twice a year. TODO fix
    updates = FlickrUpdate.find(:all)
    pentime = updates[updates.length - 2][:updated_at] - 28800
    lasttime = updates.last[:updated_at] - 28800
    guesses = Guess.find(:all, :conditions => ["added_at > ?", lasttime])
    @new_guesses = []
    guesses.each do |guess|
      photo = Photo.find(guess[:photo_id])
      person = Person.find(guess[:person_id])
      owner = Person.find(photo[:person_id])
      @new_guesses.push({:guess => guess, :photo => photo, :person => person, :owner => owner})
    end
    photos = Photo.find(:all, :conditions => ["dateadded > ?", pentime])
    @new_photos_count = photos.length;
    
    raw_people = Person.find(:all)
    @people = []
    raw_people.each do |person|
      # create an object descriptive of this person
      all_photos = Photo.find_all_by_person_id(person.id)
      all_guesses = Guess.find_all_by_person_id(person.id)
      add_person = {
        :person => person,
        :photocount => all_photos.length,
        :guesscount => all_guesses.length
      }
      # step through existing entries in @people
      found = nil
      @people.each do |person_list|
        # if we find an item in the array with the same guess count
        if person_list[:guesscount] == add_person[:guesscount]
          # add this person to the list
          person_list[:people].push(add_person)
          found = :true
          break
        end
      end
      # if it wasn't found
      if !found
        # create a new entry
        @people.push({:guesscount => add_person[:guesscount], :people => [add_person]})
      end
    end
    # sort people lists
    @people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}
    # get the counts...
    @total_participants = raw_people.length
    @total_posters_only = 0
    @total_single_guessers = 0
    @people.each do |person_list|
      if person_list[:guesscount] == 1 then @total_single_guessers = person_list[:people].length end
      if person_list[:guesscount] == 0 then @total_posters_only = person_list[:people].length end
    end
    @total_correct_guessers = @total_participants - @total_posters_only
    @report_date = Time.now
    @member_count = get_gwsf_member_count()
    @unfound_count = Photo.find_all_by_game_status('unfound').length + Photo.find_all_by_game_status('unconfirmed').length
  end

  # get the group member count for the report
  def get_gwsf_member_count
    # set the particulars
    flickr_url = 'http://api.flickr.com/services/rest/'
    flickr_method = 'flickr.groups.getInfo'
    gwsf_id = '32053327@N00'
    flickr_credentials = FlickrCredentials.new
    # generate the api signature
    sig_raw = flickr_credentials.secret + 'api_key' + flickr_credentials.api_key + 'auth_token' + flickr_credentials.auth_token + 'group_id' + gwsf_id + 'method' + flickr_method
    api_sig = MD5.hexdigest(sig_raw)
    page_url =  flickr_url + '?method=' + flickr_method +
                '&api_key=' + flickr_credentials.api_key +
		'&auth_token=' + flickr_credentials.auth_token +
                '&api_sig=' + api_sig + '&group_id=' + gwsf_id
    # get the page
    page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
    # state the value of the member attribute to return it
    XmlSimple.xml_in(page_xml)['group'][0]['members'][0]
  end

end
