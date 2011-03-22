class PeopleController < ApplicationController

  def find
    username = params[:person][:username]
    person = Person.find_by_multiple_fields username
    if person
      redirect_to person_path person
    else
      flash[:find_person_error] = username
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

  def old_show
    redirect_to person_path params[:id]
  end

  caches_page :show
  def show
    @person = Person.find params[:id]

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

    @guesses =
      Guess.find_all_by_person_id @person.id, :include => { :photo => :person }
    @favorite_posters = @person.favorite_posters
    @posters = @guesses.group_by { |guess| guess.photo.person }.sort \
      do |x,y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @posts = Photo.find_all_by_person_id @person.id, :include => { :guesses => :person }
    @favorite_posters_of = @person.favorite_posters_of
    @unfound_photos = Photo.all :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ]
    @revealed_photos =
      Photo.find_all_by_person_id_and_game_status @person.id, 'revealed'
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

  caches_page :map
  def map
    @person = Person.find params[:id]
  end

end
