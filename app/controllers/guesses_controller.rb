class GuessesController < ApplicationController

  def report
    @report_date = Time.now

    # to skip an update...
    # For some reason FlickrUpdate[:updated_at] is GMT and Guess[:added_at] is
    # local time (without a time zone). The following code reduces pentime and
    # lasttime by a hardcoded subtrahend to allow comparison. The subtrahend
    # should be 28800 for PST and 25200 for PDT, which means editing the source
    # twice a year. TODO fix
    updates = FlickrUpdate.find(:all)

    lasttime = updates.last[:updated_at] - 28800
    @guesses = Guess.find(:all, :conditions => ["added_at > ?", lasttime],
      :include => [ { :photo => :person }, :person ])
    @guessers = []
    @guesses_by_guesser = {}
    @guesses.each do |guess|
      if ! @guessers.include? guess.person
        @guessers.push guess.person
      end
      guessers_guesses = @guesses_by_guesser[guess.person]
      if ! guessers_guesses
        guessers_guesses = []
        @guesses_by_guesser[guess.person] = guessers_guesses
      end
      guessers_guesses.push guess
    end
    @guessers.sort! { |x,y|
      c = @guesses_by_guesser[y].length <=> @guesses_by_guesser[x].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase }

    pentime = updates[updates.length - 2][:updated_at] - 28800
    @new_photos_count =
      Photo.count(:all, :conditions => ["dateadded > ?", pentime])
    @unfound_count = Photo.count(:all,
      :conditions => "game_status in ('unfound', 'unconfirmed')");
    
    people = Person.find(:all)
    @posts_per_person = Photo.count(:all, :group => :person_id)
    @guesses_per_person = Guess.count(:all, :group => :person_id)
    @people_by_guess_count = []
    people.each do |person|
      guess_count = @guesses_per_person[person.id] || 0
      people_with_guess_count =
        @people_by_guess_count.find { |x| x[:guess_count] == guess_count }
      if people_with_guess_count
        people_with_guess_count[:people].push person
      elsif
        @people_by_guess_count.push(
	  { :guess_count => guess_count, :people => [person] })
      end
    end
    @people_by_guess_count.sort! { |x, y| y[:guess_count] <=> x[:guess_count] }

    @revelations = Revelation.find(:all,
      :conditions => [ "added_at > ?", lasttime ], 
      :include => [ :person, :photo ])
    @revelations_by_person = []
    @revelations.each do |revelation|
      revelations_with_person =
        @revelations_by_person.find { |x| x[:person] == revelation.person }
      if revelations_with_person
        revelations_with_person[:revelations].push revelation
      elsif
        @revelations_by_person.push(
          { :person => revelation.person, :revelations => [revelation] })
      end
    end
    @revelations_by_person.sort! {|x, y|
      x[:person].username.downcase <=> y[:person].username.downcase }

    @total_participants = people.length
    @total_posters_only = people_with @people_by_guess_count, 0
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = get_gwsf_member_count
    @total_single_guessers = people_with @people_by_guess_count, 1

  end

  def people_with(people_by_guess_count, guess_count)
    people_with_guess_count =
      people_by_guess_count.find { |x| x[:guess_count] == guess_count }
    people_with_guess_count ? people_with_guess_count[:people].length : 0
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

    @latest_update = FlickrUpdate.local_latest_update_times(1)[0]
    
    @last_days = []
    (1..7).each do |num|
      dates = { :begin => (@latest_update - num.day).beginning_of_day,
        :end => (@latest_update - (num - 1).day).beginning_of_day }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_days.push({ :dates => dates, :scores => scores })
    end
    
    thisweek_dates = { :begin => @latest_update.beginning_of_week - 1.day,
      :end => @latest_update }
    thisweek_scores = get_scores_from_date(thisweek_dates[:begin], nil)
    @last_weeks = [{ :dates => thisweek_dates, :scores => thisweek_scores }]
    (1..5).each do |num|
      dates = {
        :begin => (@latest_update - num.week).beginning_of_week - 1.day,
        :end => (@latest_update - (num - 1).week).beginning_of_week - 1.day }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_weeks.push({ :dates => dates, :scores => scores })
    end
    
    thismonth_dates = { :begin => @latest_update.beginning_of_month,
      :end => @latest_update }
    thismonth_scores = get_scores_from_date(thismonth_dates[:begin], nil)
    @last_months = [{ :dates => thismonth_dates, :scores => thismonth_scores }]
    (1..5).each do |num|
      dates = { :begin => (@latest_update - num.month).beginning_of_month,
        :end => (@latest_update - (num - 1).month).beginning_of_month }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_months.push({ :dates => dates, :scores => scores })
    end
    
    thisyear_dates = { :begin => @latest_update.beginning_of_year,
      :end => @latest_update }
    thisyear_scores = get_scores_from_date(thisyear_dates[:begin], nil)
    @last_years = [{:dates => thisyear_dates, :scores => thisyear_scores}]
    (1..2).each do |num|
      dates = { :begin => (@latest_update - num.year).beginning_of_year,
        :end => (@latest_update - (num - 1).year).beginning_of_year }
      scores = get_scores_from_date(dates[:begin], dates[:end])
      @last_years.push({ :dates => dates, :scores => scores })
    end
    
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
