class GuessesController < ApplicationController
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

  def report_with_images
    # to skip an update...
    # For some reason FlickrUpdate[:updated_at] is GMT and Guess[:added_at] is
    # local time (without a time zone). The following code reduces pentime and
    # lasttime by a hardcoded subtrahend to allow comparison. The subtrahend
    # should be 28800 for PST and 25200 for PDT, which means editing the source
    # twice a year. TODO fix
    updates = FlickrUpdate.find(:all)

    lasttime = updates.last[:updated_at] - 28800
    guesses = Guess.find(:all, :conditions => ["added_at > ?", lasttime],
      :include => [ { :photo => :person }, :person ])
    @new_guesses = []
    @guessers = []
    @guesses_by_person = {}
    guesses.each do |guess|
      @new_guesses.push({ :guess => guess, :photo => guess.photo,
        :person => guess.person, :owner => guess.photo.person })
      if ! @guessers.include? guess.person
        @guessers.push guess.person
      end
      persons_guesses = @guesses_by_person[guess.person]
      if ! persons_guesses
        persons_guesses = []
        @guesses_by_person[guess.person] = persons_guesses
      end
      persons_guesses.push guess
    end
    @guessers.sort! { |x,y|
      c = @guesses_by_person[y].length <=> @guesses_by_person[x].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase }

    pentime = updates[updates.length - 2][:updated_at] - 28800
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

  def get_gwsf_member_count
    flickr_url = 'http://api.flickr.com/services/rest/'
    flickr_method = 'flickr.groups.getInfo'
    gwsf_id = '32053327@N00'
    flickr_credentials = FlickrCredentials.new
    sig_raw = flickr_credentials.secret + 'api_key' + flickr_credentials.api_key + 'auth_token' + flickr_credentials.auth_token + 'group_id' + gwsf_id + 'method' + flickr_method
    api_sig = MD5.hexdigest(sig_raw)
    page_url =  flickr_url + '?method=' + flickr_method +
                '&api_key=' + flickr_credentials.api_key +
		'&auth_token=' + flickr_credentials.auth_token +
                '&api_sig=' + api_sig + '&group_id=' + gwsf_id
    page_xml = Net::HTTP.get_response(URI.parse(page_url)).body
    XmlSimple.xml_in(page_xml)['group'][0]['members'][0]
  end

  def treasures
    @longest_guesses = add_date_distances(Guess.longest)
    @shortest_guesses = add_date_distances(Guess.shortest)
  end

  def add_date_distances(guesses)
    annotated_guesses = []
    guesses.each do |guess|
      annotated_guesses.push({ :guess => guess, :elapsed_pretty =>
        get_date_distance(guess.photo.dateadded, guess.guessed_at)})
    end
    annotated_guesses
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

  def correct
    @guesses_count = Guess.count();

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

end
