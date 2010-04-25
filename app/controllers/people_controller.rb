class PeopleController < ApplicationController

  caches_page :list
  def list
    photo_counts = Photo.count :all, :group => 'person_id'

    guess_counts = Guess.count :all, :group => 'person_id'

    guess_rates_list = Person.find_by_sql(
      'select ' +
        'person_id id, ' +
        'count(*) / datediff(now(), min(guessed_at)) rate ' +
      'from guesses group by person_id')
    guess_rates = {}
    guess_rates_list.each do |rate|
      guess_rates[rate.id] = rate.rate.to_f
    end

    @people = Person.find(:all).map do |person|
      {
        :person => person,
        :username => person.username.downcase,
        :photo_count =>
          photo_counts[person.id].nil? ? 0 : photo_counts[person.id],
        :guess_count => 
          guess_counts[person.id].nil? ? 0 : guess_counts[person.id],
        :guess_rate => guess_rates[person.id]
      }
    end

    @people.sort! do |x, y|
      c = y[:guess_count] <=> x[:guess_count]
      c = c != 0 ? c : y[:photo_count] <=> x[:photo_count]
      c != 0 ? c : x[:username] <=> y[:username]
    end

  end

  caches_page :show
  def show
    @person = Person.find params[:id]
    
    @unfound_photos = Photo.find :all, :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ]
    @revealed_photos = Photo.find_all_by_person_id_and_game_status @person.id,
      'revealed'
    
    # Map of guessers to this person's posts
    posts = Photo.find_all_by_person_id @person.id,
      :include => { :guesses => :person }
    @posted_count = posts.length
    guessers = {}
    posts.each do |photo|
      photo.guesses.each do |guess|
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
    guesses = Guess.find_all_by_person_id @person.id,
      :include => { :photo => :person }
    @guessed_count = guesses.length
    posters = {}
    guesses.each do |guess|
      person = guess.photo.person
      poster = posters[person]
      if ! poster
        poster = { :person => person, :photos => [] }
        posters[person] = poster
      end
      poster[:photos].push guess.photo
    end
    @posters = posters.values
    @posters.sort! { |x,y| y[:photos].count <=> x[:photos].count }

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
