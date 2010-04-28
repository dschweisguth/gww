class GuessesController < ApplicationController

  caches_page :longest_and_shortest
  def longest_and_shortest
    @longest_guesses = add_date_distances Guess.longest
    @shortest_guesses = add_date_distances Guess.shortest
  end

  def add_date_distances(guesses)
    annotated_guesses = []
    guesses.each do |guess|
      annotated_guesses.push({ :guess => guess, :elapsed_pretty =>
        get_date_distance(guess.photo.dateadded, guess.guessed_at) })
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
    if (years > 0) then desc.push("#{years}&nbsp;years") end
    if (months > 0) then desc.push("#{months}&nbsp;months") end
    if (days > 0) then desc.push("#{days}&nbsp;days") end
    if (hours > 0) then desc.push("#{hours}&nbsp;hours") end
    if (minutes > 0) then desc.push("#{minutes}&nbsp;minutes") end
    if (seconds > 0) then desc.push("#{seconds}&nbsp;seconds") end
    desc.join(", ")
  end

  caches_page :by_day_week_month_and_year
  def by_day_week_month_and_year
    @guesses_count = Guess.count();

    @latest_update = FlickrUpdate.latest.created_at.getlocal
    
    @last_days = []
    (1..7).each do |num|
      dates = { :begin => (@latest_update - num.day).beginning_of_day,
        :end => (@latest_update - (num - 1).day).beginning_of_day }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @last_days.push({ :dates => dates, :scores => scores })
    end
    
    thisweek_dates = { :begin => @latest_update.beginning_of_week - 1.day,
      :end => @latest_update }
    thisweek_scores = get_scores_from_date thisweek_dates[:begin], nil
    @last_weeks = [ { :dates => thisweek_dates, :scores => thisweek_scores } ]
    (1..5).each do |num|
      dates = {
        :begin => (@latest_update - num.week).beginning_of_week - 1.day,
        :end => (@latest_update - (num - 1).week).beginning_of_week - 1.day }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @last_weeks.push({ :dates => dates, :scores => scores })
    end
    
    thismonth_dates = { :begin => @latest_update.beginning_of_month,
      :end => @latest_update }
    thismonth_scores = get_scores_from_date thismonth_dates[:begin], nil
    @last_months =
      [ { :dates => thismonth_dates, :scores => thismonth_scores } ]
    (1..5).each do |num|
      dates = { :begin => (@latest_update - num.month).beginning_of_month,
        :end => (@latest_update - (num - 1).month).beginning_of_month }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @last_months.push({ :dates => dates, :scores => scores })
    end
    
    thisyear_dates = { :begin => @latest_update.beginning_of_year,
      :end => @latest_update }
    thisyear_scores = get_scores_from_date thisyear_dates[:begin], nil
    @last_years = [ {:dates => thisyear_dates, :scores => thisyear_scores} ]
    years_of_guessing = Time.now.getutc.year - Guess.first.guessed_at.year
    (1..years_of_guessing).each do |num|
      dates = { :begin => (@latest_update - num.year).beginning_of_year,
        :end => (@latest_update - (num - 1).year).beginning_of_year }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @last_years.push({ :dates => dates, :scores => scores })
    end
    
  end
  
  def get_scores_from_date(begin_date, end_date)
    if begin_date && end_date
      conditions = [ "guessed_at > ? and guessed_at < ?",
        begin_date.getutc, end_date.getutc ]
    elsif begin_date
      conditions = [ "guessed_at > ?", begin_date.getutc ]
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
    return_people.sort! { |x,y| y[:guesscount] <=> x[:guesscount] }
  end

end
