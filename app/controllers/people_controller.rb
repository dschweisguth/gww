class PeopleController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    raw_people = Person.find(:all)
    @people = []
    raw_people.each do |person|
      all_photos = Photo.find_all_by_person_id(person.id)
      all_guesses = Guess.find_all_by_person_id(person.id)
      add_person = {
        :person => person,
        :photocount => all_photos.length,
        :guesscount => all_guesses.length
      }
      @people.push(add_person)
    end
    @people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}
  end

  def report
    # to skip an update...
    updates = FlickrUpdate.find(:all)
    penupdate = updates[updates.length - 2]
    pentime = penupdate[:updated_at] - 25200 #28800;
    lastupdate = FlickrUpdate.find(:all).last
    lasttime = lastupdate[:updated_at] - 25200 #28800
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
    secret = 'xxxxx' # :NOTE: replace with your API secret
    api_key = 'xxxxx' # :NOTE: replace with your API key
    auth_token = 'xxxxx' # :NOTE: replace with your auth token
    gwsf_id = '32053327@N00'
    # generate the api signature
    sig_raw = secret + 'api_key' + api_key + 'auth_token' + auth_token + 'group_id' + gwsf_id + 'method' + flickr_method
    api_sig = MD5.hexdigest(sig_raw)
    page_url =  flickr_url + '?method=' + flickr_method +
                '&api_key=' + api_key + '&auth_token=' + auth_token +
                '&api_sig=' + api_sig + '&group_id=' + gwsf_id
    # get the page
    page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
    # state the value of the member attribute to return it
    XmlSimple.xml_in(page_xml)['group'][0]['members'][0]
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

  def guesses
    lastupdate = FlickrUpdate.find(:all).last
    lasttime = lastupdate[:updated_at] - 25200 #28800;
    # get the guesses after each time
    #@overall = get_scores_from_date(nil, nil)
    
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
  
  def latest_guesses
    @person = Person.find(params[:id])
    @guesses = Guess.find(:all, :conditions => ["person_id = ?", params[:id]])
    @guesses = Guess.find_all_by_person_id(params[:id])
    @guesses.sort! {|x,y| y[:guessed_at] <=> x[:guessed_at]}
  end

  def latest_posts
    @person = Person.find(params[:id])
    @photos = Photo.find_all_by_person_id(params[:id])
    @photos.sort! {|x,y| y[:dateadded] <=> x[:dateadded]}
  end
  
  def commented_on
    @person = Person.find(params[:id])
    @comments = Comment.find_all_by_userid(@person[:flickrid])
    @photos = []
    @comments.each do |comment|
      photo = Photo.find(comment[:photo_id])
      @photos.push(photo) if !@photos.include?(photo)
    end
    @photos.sort! {|x,y| y[:lastupdate] <=> x[:lastupdate]}
  end
  
  def show
    @person = Person.find(params[:id])
    
    # put together a lookup of who has guessed the photos this person posted
    raw_photos = Photo.find_all_by_person_id(params[:id])
    @posted_count = raw_photos.length
    photos_by_guesser = {}
    # step through the photos
    raw_photos.each do |photo|
      # find all the guesses on this photo
      photo_guesses = Guess.find_all_by_photo_id(photo[:id])
      # step through the guesses (usually just one)
      photo_guesses.each do |guess|
        guess_person = Person.find(guess[:person_id])
        if !photos_by_guesser[guess_person]
          photos_by_guesser[guess_person] = []
        end
        photos_by_guesser[guess_person].push(photo)
      end
    end
    @photo_lookup = []
    photos_by_guesser.each do |person, photos|
      @photo_lookup.push({:username => person[:username], :person_id => person[:id], :photos => photos, :count => photos.length})
    end
    @photo_lookup.sort! {|x,y| y[:count] <=> x[:count]}
    
    # get unfound & revealed lists
    @unfound_photos = Photo.find_all_by_person_id_and_game_status(params[:id], 'unfound')
    @unfound_photos.concat(Photo.find_all_by_person_id_and_game_status(params[:id], 'unconfirmed'))
    @revealed_photos = Photo.find_all_by_person_id_and_game_status(params[:id], 'revealed')
    
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

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      flash[:notice] = 'Person was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    Person.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
