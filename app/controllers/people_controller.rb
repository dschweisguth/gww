class PeopleController < ApplicationController

  caches_page :list
  def list
    @people = Person.all_sorted params[:sorted_by], params[:order]
  end

  caches_page :top_guessers
  def top_guessers
    @latest_update = FlickrUpdate.latest.created_at.getlocal
    
    @days = []
    (0..6).each do |num|
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

    scores.values.each do |guessers_with_score|
      guessers_with_score.each \
        { |guesser| guesser[:downcased_username] = guesser.username.downcase }
      guessers_with_score.sort! \
        { |a, b| a[:downcased_username] <=> b[:downcased_username] }
    end

    scores
  end
  private :get_scores_from_date

  caches_page :show
  def show
    @person = Person.find params[:id]

    @place, @tied = standing @person
   
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
    @oldest_guess = Guess.oldest @person
    @fastest_guess = Guess.fastest @person
    @longest_lasting_guess = Guess.longest_lasting @person
    @shortest_lasting_guess = Guess.shortest_lasting @person

    @guesses =
      Guess.find_all_by_person_id @person.id, :include => { :photo => :person }
    @posters = @guesses.group_by { |guess| guess.photo.person }.sort \
      do |x,y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @unfound_photos = Photo.all :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ]
    @revealed_photos =
      Photo.find_all_by_person_id_and_game_status @person.id, 'revealed'
    
    @posts = Photo.find_all_by_person_id @person.id,
      :include => { :guesses => :person }
    @guessers = group_by_guessers @posts
    
  end

  def standing(person)
    place = 1
    tied = false
    scores_by_person = Guess.count :group => :person_id
    people_by_score = scores_by_person.keys.group_by \
      { |person_id| scores_by_person[person_id] }
    scores = people_by_score.keys.sort { |a, b| b <=> a }
    scores.each do |score|
      people_with_score = people_by_score[score]
      if people_with_score.include? person.id
        tied = people_with_score.length > 1
        break
      else
        place += people_with_score.length
      end
    end
    return place, tied
  end
  private :standing

  def group_by_guessers(posts)
    guessers = {}
    posts.each do |post|
      post.guesses.each do |guess|
        guesser = guess.person
        guessers_guesses = guessers[guesser]
        if ! guessers_guesses
          guessers_guesses = []
          guessers[guesser] = guessers_guesses
        end
	guessers_guesses.push post
      end
    end
    guessers.sort do |x,y|
      c = y[1].length <=> x[1].length
      c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
    end
  end
  private :group_by_guessers

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
