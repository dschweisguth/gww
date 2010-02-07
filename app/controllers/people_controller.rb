class PeopleController < ApplicationController
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
    guesses = Guess.find(:all, :conditions => ["added_at > ?", lasttime],
      :include => [ { :photo => :person }, :person ])
    @new_guesses = []
    guesses.each do |guess|
      @new_guesses.push({ :guess => guess, :photo => guess.photo,
        :person => guess.person, :owner => guess.photo.person })
    end
    photos = Photo.find(:all, :conditions => ["dateadded > ?", pentime])
    @new_photos_count = photos.length;
    
    raw_people = Person.find(:all)
    posts_per_person = Photo.count(:all, :group => :person_id)
    guesses_per_person = Guess.count(:all, :group => :person_id)
    @people = []
    raw_people.each do |person|
      photocount = posts_per_person[person.id]
      if photocount.nil?
        photocount = 0
      end
      guesscount = guesses_per_person[person.id]
      if guesscount.nil?
        guesscount = 0
      end
      add_person = {
        :person => person,
        :photocount => photocount,
        :guesscount => guesscount
      }
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
        @people.push({ :guesscount => add_person[:guesscount],
          :people => [add_person]})
      end
    end
    @people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}

    # Get counts
    @total_participants = raw_people.length
    @total_posters_only = 0
    @total_single_guessers = 0
    @people.each do |person_list|
      if person_list[:guesscount] == 1
        @total_single_guessers = person_list[:people].length
      end
      if person_list[:guesscount] == 0
        @total_posters_only = person_list[:people].length
      end
    end
    @total_correct_guessers = @total_participants - @total_posters_only
    @report_date = Time.now
    @member_count = get_gwsf_member_count()
    @unfound_count = Photo.count(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')");

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

  def guesses
    lasttime = adj_last_update_time
    
    @last_days = []
    (1..7).each do |num|
      dates = { :begin => (lasttime - num.day).beginning_of_day,
        :end => (lasttime - (num - 1).day).beginning_of_day }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_days.push({ :dates => dates, :scores => scores })
    end
    
    thisweek_dates = { :begin => lasttime.beginning_of_week - 1.day,
      :end => lasttime }
    thisweek_scores = get_scores_from_date(thisweek_dates[:begin], nil)
    @last_weeks = [{ :dates => thisweek_dates, :scores => thisweek_scores }]
    (1..5).each do |num|
      dates = { :begin => (lasttime - num.week).beginning_of_week - 1.day,
        :end => (lasttime - (num - 1).week).beginning_of_week - 1.day }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_weeks.push({ :dates => dates, :scores => scores })
    end
    
    thismonth_dates = { :begin => lasttime.beginning_of_month,
      :end => lasttime }
    thismonth_scores = get_scores_from_date(thismonth_dates[:begin], nil)
    @last_months = [{ :dates => thismonth_dates, :scores => thismonth_scores }]
    (1..5).each do |num|
      dates = { :begin => (lasttime - num.month).beginning_of_month,
        :end => (lasttime - (num - 1).month).beginning_of_month }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_months.push({ :dates => dates, :scores => scores })
    end
    
    thisyear_dates = { :begin => lasttime.beginning_of_year, :end => lasttime }
    thisyear_scores = get_scores_from_date(thisyear_dates[:begin], nil)
    @last_years = [{:dates => thisyear_dates, :scores => thisyear_scores}]
    (1..2).each do |num|
      dates = { :begin => (lasttime - num.year).beginning_of_year,
        :end => (lasttime - (num - 1).year).beginning_of_year }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_years.push({ :dates => dates, :scores => scores })
    end
    
    @report_date = lasttime
  end
  
  def get_scores_from_date(begin_date, end_date)
    if begin_date && end_date
      conditions =
        [ "guessed_at > ? and guessed_at < ?", begin_date, end_date ]
    elsif begin_date
      conditions = [ "guessed_at > ?", begin_date ]
    else
      conditions = []
    end
    guesses = Guess.find(:all, :conditions => conditions,:include => :person)

    guessers = {}
    guesses.each do |guess|
      guessers[guess.person] ||= []
      guessers[guess.person].push(guess)
    end

    return_people = []
    guessers.each do |person, guesses|
      add_person = { :person => person, :guesscount => guesses.length }
      found = nil
      return_people.each do |person_list|
        if person_list[:guesscount] == add_person[:guesscount]
          person_list[:people].push(add_person)
          found = :true
          break
        end
      end
      if !found
        # create a new entry
        return_people.push({ :guesscount => add_person[:guesscount],
          :people => [add_person] })
      end
    end
    return_people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}
  end

  def list
    photo_counts = Photo.count(:all, :group => 'person_id')
    guess_counts = Guess.count(:all, :group => 'person_id')
    people = Person.find(:all)
    @people = []
    people.each do |person|
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
    
    @unfound_photos = Photo.find(:all, :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ])
    @revealed_photos = Photo.find_all_by_person_id_and_game_status(@person.id,
      'revealed')
    
    missing_person = Person.new
    missing_person.username = 'unknown'

    # Map of guessers to this person's posts
    posts = Photo.find_all_by_person_id(@person.id,
      :include => { :guesses => :person })
    @posted_count = posts.length
    guessers = {}
    posts.each do |photo|
      photo.guesses.each do |guess|
	if guess.person.nil?
          guess.person = missing_person
	end
        guesser = guessers[guess.person]
        if ! guesser
          guesser = { :person => guess.person, :photos => [] }
          guessers[guess.person] = guesser
        end
        guesser[:photos].push photo
      end
    end
    @guessers = guessers.values
    @guessers.sort! { |x,y| y[:photos].length <=> x[:photos].length }
    
    # Map of posters to this person's guesses
    guesses = Guess.find_all_by_person_id(@person.id, :include => :photo)
    @guessed_count = guesses.length
    posters = {}
    guesses.each do |guess|
      if guess.photo.person_id == 0
        person = missing_person
      else
        person = Person.find(guess.photo.person_id)
      end
      poster = posters[person]
      if ! poster
        poster = { :person => person, :photos => [] }
        posters[person] = poster
      end
      poster[:photos].push(guess.photo)
    end
    @posters = posters.values
    @posters.sort! { |x,y| y[:photos].count <=> x[:photos].count }

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
  
end
