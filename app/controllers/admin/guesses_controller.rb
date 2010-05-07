class Admin::GuessesController < ApplicationController

  caches_page :report
  def report
    @report_date = Time.now

    updates = FlickrUpdate.find :all, :order => "id desc", :limit => 2

    @guesses = Guess.find :all,
      :conditions => [ "added_at > ?", updates[0].created_at ],
      :include => [ { :photo => :person }, :person ]
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

    @new_photos_count =
      Photo.count :all,
        :conditions => [ "dateadded > ?", updates[1].created_at ]
    @unfound_count = Photo.count :all,
      :conditions => "game_status in ('unfound', 'unconfirmed')";
    
    people = Person.find :all
    @posts_per_person = Photo.count :all, :group => :person_id
    @guesses_per_person = Guess.count :all, :group => :person_id
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

    @weekly_scores = recent_scores people, 7
    @monthly_scores = recent_scores people, 30

    @revelations = Revelation.find :all,
      :conditions => [ "added_at > ?", updates[0].created_at ], 
      :include => { :photo => :person }
    @revelations_by_person = []
    @revelations.each do |revelation|
      revelations_with_person =
        @revelations_by_person.find { |x|
          x[:person] == revelation.photo.person }
      if revelations_with_person
        revelations_with_person[:revelations].push revelation
      elsif
        @revelations_by_person.push({ :person => revelation.photo.person,
          :revelations => [ revelation ] })
      end
    end
    @revelations_by_person.sort! { |x, y|
      x[:person].username.downcase <=> y[:person].username.downcase }

    @total_participants = people.length
    @total_posters_only = people_with @people_by_guess_count, 0
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = updates[0].member_count
    @total_single_guessers = people_with @people_by_guess_count, 1

  end

  def recent_scores(people, days)
    scores_by_id = Guess.count :all, :group => :person_id,
      :conditions => "datediff(now(), guessed_at) < #{days}"

    people_by_score = {}
    people.each do |person|
      score = scores_by_id[person.id]
      if score && score > 1
        people_with_score = people_by_score[score]
        if ! people_with_score
          people_with_score = []
          people_by_score[score] = people_with_score
        end
        people_with_score.push person
      end
    end

    scores = people_by_score.keys.sort! { |x, y| y <=> x }
    people_count = 0
    scores_to_keep = {}
    scores.each do |score|
      people_with_score = people_by_score[score]
      scores_to_keep[score] = people_with_score
      people_count += people_with_score.length
      break if people_count >= 3
    end
    people_by_score = scores_to_keep

    people_by_score.each do |count, people|
      people.sort!
    end

    people_by_score
  end

  def people_with(people_by_guess_count, guess_count)
    people_with_guess_count =
      people_by_guess_count.find { |x| x[:guess_count] == guess_count }
    people_with_guess_count ? people_with_guess_count[:people].length : 0
  end

end
