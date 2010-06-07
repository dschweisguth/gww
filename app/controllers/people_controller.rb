class PeopleController < ApplicationController

  caches_page :list
  def list
    post_counts = Photo.count :all, :group => 'person_id'
    guess_counts = Guess.count :all, :group => 'person_id'
    guesses_per_days = Guess.count_by_person_per_day

    @people = Person.find :all
    @people.each do |person|
      person[:downcased_username] = person.username.downcase
      person[:post_count] = post_counts[person.id] || 0
      person[:guess_count] = guess_counts[person.id] || 0
      person[:guesses_per_day] = guesses_per_days[person.id] || 0
      person[:posts_per_guess] =
        person[:post_count].to_f / person[:guess_count]
    end

    sorted_by = params[:sorted_by]
    @people.sort! do |x, y|
      username = -criterion(x, y, :username)
      case sorted_by
      when 'username'
        first_applicable username
      when 'score'
        first_applicable criterion(x, y, :guess_count),
          criterion(x, y, :post_count), username
      when 'posts'
        first_applicable criterion(x, y, :post_count), username
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
    end

  end

  def criterion(element1, element2, property)
    element2[property] <=> element1[property]
  end

  def first_applicable(*criteria)
    criteria.find(lambda { 0 }) { |criterion| criterion != 0 }
  end

  caches_page :show
  def show
    @person = Person.find params[:id]

    @first_guess = Guess.first :conditions => [ 'person_id = ?', @person ],
      :order => 'guessed_at', :include => :photo
    @first_post = Photo.first :conditions => [ 'person_id = ?', @person ],
      :order => 'dateadded'

    weekly_high_scorers = Person.high_scorers 7
    if weekly_high_scorers.include? @person
      @weekly_high_scorers = weekly_high_scorers
    end
    monthly_high_scorers = Person.high_scorers 30
    if monthly_high_scorers.include? @person
      @monthly_high_scorers = monthly_high_scorers
    end
    
    # Map of posters to this person's guesses
    guesses = Guess.find_all_by_person_id @person.id,
      :include => { :photo => :person }
    @guessed_count = guesses.length
    @posters = []
    guesses.each do |guess|
      poster = guess.photo.person
      if ! @posters.include? poster
        @posters.push poster
        poster[:photos] = []
      end
      poster[:photos].push guess.photo
    end
    @posters.sort! do |x,y|
      c = y[:photos].length <=> x[:photos].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase
    end

    @unfound_photos = Photo.find :all, :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ]
    @revealed_photos = Photo.find_all_by_person_id_and_game_status @person.id,
      'revealed'
    
    # Map of guessers to this person's posts
    posts = Photo.find_all_by_person_id @person.id,
      :include => { :guesses => :person }
    @posted_count = posts.length
    @guessers = []
    posts.each do |photo|
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
