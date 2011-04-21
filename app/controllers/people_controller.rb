class PeopleController < ApplicationController
  include Color

  def find
    username = params[:username]
    person = Person.find_by_multiple_fields username
    if person
      redirect_to person_path person
    else
      flash[:find_person_error] = username
      #noinspection RubyResolve
      redirect_to root_path
    end
  end

  caches_page :index
  def index
    @people = Person.all_sorted params[:sorted_by], params[:order]
  end

  caches_page :nemeses
  def nemeses
    @nemeses = Person.nemeses
  end

  caches_page :top_guessers
  def top_guessers
    @days, @weeks, @months, @years = Person.top_guessers Time.now
  end

  caches_page :show
  def show
    @person = Person.find params[:id]

    @mapped_post_and_guess_count =
      Photo.all_mapped_count(@person.id) + Guess.all_mapped_count(@person.id)

    @place, @tied = Person.standing @person
    @posts_place, @posts_tied = Person.posts_standing @person

    now = Time.now
    weekly_high_scorers = Person.high_scorers now, 7
    if weekly_high_scorers.include? @person
      @weekly_high_scorers = weekly_high_scorers
    end
    monthly_high_scorers = Person.high_scorers now, 30
    if monthly_high_scorers.include? @person
      @monthly_high_scorers = monthly_high_scorers
    end
    weekly_top_posters = Person.top_posters now, 7
    if weekly_top_posters.include? @person
      @weekly_top_posters = weekly_top_posters
    end
    monthly_top_posters = Person.top_posters now, 30
    if monthly_top_posters.include? @person
      @monthly_top_posters = monthly_top_posters
    end

    @first_guess = Guess.first_by @person
    @first_post = Photo.first_by @person
    @most_recent_guess = Guess.most_recent_by @person
    @most_recent_post = Photo.most_recent_by @person

    @oldest_guess = Guess.oldest @person
    @fastest_guess = Guess.fastest @person
    @longest_lasting_guess = Guess.longest_lasting @person
    @shortest_lasting_guess = Guess.shortest_lasting @person
    @oldest_unfound = Photo.oldest_unfound @person
    @most_commented = Photo.most_commented @person
    @most_viewed = Photo.most_viewed @person

    @guesses = Guess.where(:person_id => @person).includes(:photo => :person)
    @favorite_posters = @person.favorite_posters
    @posters = @guesses.group_by { |guess| guess.photo.person }.sort \
      do |x,y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @posts = Photo.where(:person_id => @person).includes(:guesses => :person)
    @favorite_posters_of = @person.favorite_posters_of
    @unfound_photos =
      Photo.where("person_id = ? AND game_status in ('unfound', 'unconfirmed')", @person)
    @revealed_photos = Photo.find_all_by_person_id_and_game_status @person, 'revealed'
    @guessers = group_by_guessers @posts
    
  end

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
	      guessers_guesses << post
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
    @guesses = Guess.where(:person_id => params[:id]) \
      .order('commented_at desc').includes(:photo => :person)
  end

  caches_page :posts
  def posts
    @person = Person.find params[:id]
    #noinspection RailsParamDefResolve
    @photos = Photo.where(:person_id => params[:id]).order('dateadded desc').includes(:person)
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

  caches_page :map
  def map
    person_id = params[:id]
    @person = Person.find person_id
    @posts_count = Photo.all_mapped_count person_id
    @guesses_count = Guess.all_mapped_count person_id

    posts = Photo.all_mapped params[:id]
    posts.to_a
    if ! posts.empty?
      first_dateadded = posts.first.dateadded
      last_dateadded = posts.last.dateadded
      posts.each do |post|
        if post.game_status == 'unfound' || post.game_status == 'unconfirmed'
          post[:color] = 'FFFF00'
          post[:symbol] = '?'
        elsif post.game_status == 'found'
          post[:color] = scaled_blue first_dateadded, last_dateadded, post.dateadded
          post[:symbol] = '?'
        else # revealed
          post[:color] = scaled_red first_dateadded, last_dateadded, post.dateadded
          post[:symbol] = '-'
        end
      end
    end

    guesses = Guess.all_mapped params[:id]
    guesses.to_a
    if ! guesses.empty?
      first_guessed_at = guesses.first.commented_at
      last_guessed_at = guesses.last.commented_at
      guesses.each do |guess|
        guess.photo[:color] = scaled_green first_guessed_at, last_guessed_at, guess.commented_at
        guess.photo[:symbol] = '!'
      end
    end

    photos = posts + (guesses.map &:photo)
    photos.each do |photo|
      if ! photo.latitude
        photo.latitude = photo.inferred_latitude
        photo.longitude = photo.inferred_longitude
      end
    end

    @json = photos.to_json :only => [ :id, :latitude, :longitude, :color, :symbol ]

  end

end
