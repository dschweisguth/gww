class PeopleController < ApplicationController

  caches_page :list
  def list
    post_counts = Photo.count :group => 'person_id'
    guess_counts = Guess.count :group => 'person_id'
    guesses_per_days = Guess.count_by_person_per_day

    @people = Person.all
    @people.each do |person|
      person[:downcased_username] = person.username.downcase
      person[:post_count] = post_counts[person.id] || 0
      person[:guess_count] = guess_counts[person.id] || 0
      person[:guesses_per_day] = guesses_per_days[person.id] || 0
      person[:posts_per_guess] =
        person[:post_count].to_f / person[:guess_count]
    end

    @people.sort! do |x, y|
      username = -criterion(x, y, :downcased_username)
      sorted_by = 
	case params[:sorted_by]
	when 'username'
	  first_applicable username
	when 'score'
	  first_applicable criterion(x, y, :guess_count),
	    criterion(x, y, :post_count), username
	when 'posts'
	  first_applicable criterion(x, y, :post_count),
	    criterion(x, y, :guess_count), username
	when 'guesses-per-day'
	  first_applicable criterion(x, y, :guesses_per_day),
	    criterion(x, y, :guess_count), username
	when 'posts-per-guess'
	  first_applicable criterion(x, y, :posts_per_guess),
	    criterion(x, y, :post_count), -criterion(x, y, :guess_count),
	    username
	else
	  first_applicable criterion(x, y, :guess_count),
	    criterion(x, y, :post_count), username
	end
      params[:order] == '+' ? sorted_by : -sorted_by
    end

  end

  def criterion(element1, element2, property)
    element2[property] <=> element1[property]
  end
  private :criterion

  def first_applicable(*criteria)
    criteria.find(lambda { 0 }) { |criterion| criterion != 0 }
  end
  private :first_applicable

  caches_page :top_guessers
  def top_guessers
    @latest_update = FlickrUpdate.latest.created_at.getlocal
    
    @days = []
    (1..7).each do |num|
      dates = { :begin => (@latest_update - num.day).beginning_of_day,
        :end => (@latest_update - (num - 1).day).beginning_of_day }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @days.push({ :dates => dates, :scores => scores })
    end
    
    thisweek_dates = { :begin => @latest_update.beginning_of_week - 1.day,
      :end => @latest_update }
    thisweek_scores = get_scores_from_date thisweek_dates[:begin], nil
    @weeks = [ { :dates => thisweek_dates, :scores => thisweek_scores } ]
    (1..5).each do |num|
      dates = {
        :begin => (@latest_update - num.week).beginning_of_week - 1.day,
        :end => (@latest_update - (num - 1).week).beginning_of_week - 1.day }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @weeks.push({ :dates => dates, :scores => scores })
    end
    
    thismonth_dates = { :begin => @latest_update.beginning_of_month,
      :end => @latest_update }
    thismonth_scores = get_scores_from_date thismonth_dates[:begin], nil
    @months =
      [ { :dates => thismonth_dates, :scores => thismonth_scores } ]
    (1..5).each do |num|
      dates = { :begin => (@latest_update - num.month).beginning_of_month,
        :end => (@latest_update - (num - 1).month).beginning_of_month }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @months.push({ :dates => dates, :scores => scores })
    end
    
    thisyear_dates = { :begin => @latest_update.beginning_of_year,
      :end => @latest_update }
    thisyear_scores = get_scores_from_date thisyear_dates[:begin], nil
    @years = [ {:dates => thisyear_dates, :scores => thisyear_scores} ]
    years_of_guessing = Time.now.getutc.year - Guess.first.guessed_at.year
    (1..years_of_guessing).each do |num|
      dates = { :begin => (@latest_update - num.year).beginning_of_year,
        :end => (@latest_update - (num - 1).year).beginning_of_year }
      scores = get_scores_from_date dates[:begin], dates[:end]
      @years.push({ :dates => dates, :scores => scores })
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
    guesses = Guess.all :conditions => conditions, :include => :person

    guessers = {}
    guesses.each do |guess|
      guesser = guessers[guess.person.id]
      if guesser
        guesser[:score] += 1
      else
        guess.person[:score] = 1
        guessers[guess.person.id] = guess.person
      end
    end

    scores = {}
    guessers.values.each do |guesser|
      score = scores[guesser[:score]]
      if score
        score.push guesser
      else
        scores[guesser[:score]] = [ guesser ]
      end        
    end
    scores
  end
  private :get_scores_from_date

  caches_page :show
  def show
    @person = Person.find params[:id]

    set_place_and_tied
   
    weekly_high_scorers = Person.high_scorers 7
    if weekly_high_scorers.include? @person
      @weekly_high_scorers = weekly_high_scorers
    end
    monthly_high_scorers = Person.high_scorers 30
    if monthly_high_scorers.include? @person
      @monthly_high_scorers = monthly_high_scorers
    end
 
    @first_guess = Guess.first :conditions => [ 'person_id = ?', @person ],
      :order => 'guessed_at', :include => :photo
    @first_post = Photo.first :conditions => [ 'person_id = ?', @person ],
      :order => 'dateadded'

    # Map of posters to this person's guesses
    @guesses =
      Guess.find_all_by_person_id @person.id, :include => { :photo => :person }
    @posters = group_by_owner(guesses, :photos) { |guess| guess.photo.person }
    @posters.sort! do |x,y|
      c = y[:photos].length <=> x[:photos].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase
    end

    @unfound_photos = Photo.all :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ]
    @revealed_photos =
      Photo.find_all_by_person_id_and_game_status @person.id, 'revealed'
    
    # Map of guessers to this person's posts
    @posts = Photo.find_all_by_person_id @person.id,
      :include => { :guesses => :person }
    @guessers = []
    @posts.each do |photo|
      photo.guesses.each do |guess|
        guesser = guess.person
        if ! @guessers.include? guesser
          @guessers.push guesser
          guesser[:photos] = []
        end
        guesser[:photos].push photo
      end
    end
    @guessers.sort! do |x,y|
      c = y[:photos].length <=> x[:photos].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase
    end
    
  end

  def set_place_and_tied
    scores_by_person = Guess.count :group => :person_id
    people_by_score = scores_by_person.keys.group_by \
      { |person_id| scores_by_person[person_id] }
    @place = 1
    scores = people_by_score.keys.sort { |a, b| b <=> a }
    scores.each do |score|
      people_with_score = people_by_score[score]
      if people_with_score.include? @person.id
        @tied = people_with_score.length > 1
        break
      else
        @place += people_with_score.length
      end
    end
  end
  private :set_place_and_tied

  caches_page :guesses
  def guesses
    @person = Person.find params[:id]
    @guesses = Guess.find_all_by_person_id params[:id],
      :order => "guessed_at desc", :include => { :photo => :person }
  end

  caches_page :posts
  def posts
    @person = Person.find params[:id]
    @photos = Photo.find_all_by_person_id params[:id],
      :order => "dateadded desc", :include => :person
  end
  
  caches_page :comments
  def comments
    @person = Person.find params[:id]
    photos = Comment.find_by_sql [
      'select distinct photo_id id from comments where flickrid = ?',
      @person.flickrid ]
    @photo_ids = photos.map { |p| p.id }
    @photos = Photo.paginate @photo_ids, :page => params[:page], 
      :include => [ :person, { :guesses => :person } ],
      :order => 'lastupdate desc', :per_page => 25
  end
  
end
