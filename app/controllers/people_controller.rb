class PeopleController < ApplicationController

  caches_page :list
  def list
    @people = Person.all_sorted params[:sorted_by], params[:order]
  end

  caches_page :top_guessers
  def top_guessers
    @days, @weeks, @months, @years = Person.top_guessers Time.now
  end
  
  caches_page :show
  def show
    @person = Person.find params[:id]

    @place, @tied = Person.standing @person
   
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
