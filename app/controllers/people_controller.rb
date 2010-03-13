class PeopleController < ApplicationController
  def list
    photo_counts = Photo.count(:all, :group => 'person_id')
    guess_counts = Guess.count(:all, :group => 'person_id')
    people = Person.find(:all)
    @people = []
    people.each do |person|
      add_person = {
        :person => person,
        :photocount =>
          photo_counts[person.id].nil? ? 0 : photo_counts[person.id],
        :guesscount => 
          guess_counts[person.id].nil? ? 0 : guess_counts[person.id],
      }
      @people.push(add_person)
    end
    @people.sort! {|x,y| y[:guesscount] <=> x[:guesscount]}
  end

  def show
    @person = Person.find(params[:id])
    
    @unfound_photos = Photo.find(:all, :conditions =>
      [ "person_id = ? AND game_status in ('unfound', 'unconfirmed')",
        @person.id ])
    @revealed_photos = Photo.find_all_by_person_id_and_game_status(@person.id,
      'revealed')
    
    # Map of guessers to this person's posts
    posts = Photo.find_all_by_person_id(@person.id,
      :include => { :guesses => :person })
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
    guesses = Guess.find_all_by_person_id(@person.id,
      :include => { :photo => :person })
    @guessed_count = guesses.length
    posters = {}
    guesses.each do |guess|
      person = guess.photo.person
      poster = posters[person]
      if ! poster
        poster = { :person => person, :photos => [] }
        posters[person] = poster
      end
      poster[:photos].push(guess.photo)
    end
    @posters = posters.values
    @posters.sort! { |x,y| y[:photos].count <=> x[:photos].count }

  end

  def latest_guesses
    @person = Person.find(params[:id])
    @guesses = Guess.find_all_by_person_id(params[:id],
      :order => "guessed_at desc", :include => { :photo => :person })
  end

  def latest_posts
    @person = Person.find(params[:id])
    @photos = Photo.find_all_by_person_id(params[:id],
      :order => "dateadded desc", :include => :person)
  end
  
  def commented_on
    @person = Person.find(params[:id])
    @comments = Comment.find_all_by_userid(@person[:flickrid],
      :include => { :photo => [:person, { :guesses => :person }] })
    @photos = []
    @comments.each do |comment|
      @photos.push(comment.photo) if !@photos.include?(comment.photo)
    end
    @photos.sort! {|x,y| y[:lastupdate] <=> x[:lastupdate]}
  end
  
end
