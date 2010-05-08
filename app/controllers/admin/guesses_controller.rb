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

    @weekly_high_scorers = high_scorers 7
    @monthly_high_scorers = high_scorers 30

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

  def high_scorers(days)
    people = Person.find_by_sql [
      'select p.*, count(*) score from people p, guesses g ' +
        'where p.id = g.person_id and datediff(?, g.guessed_at) < ? ' +
        'group by p.id having score > 1 order by score desc',
      Time.now.getutc.strftime('%Y-%m-%d'), days
    ]
    high_scorers = []
    current_score = nil
    people.each do |person|
      break if high_scorers.length >= 3 &&
        person[:score] < current_score
      high_scorers.push person
      current_score = person[:score]
    end
    high_scorers
  end

  def people_with(people_by_guess_count, guess_count)
    people_with_guess_count =
      people_by_guess_count.find { |x| x[:guess_count] == guess_count }
    people_with_guess_count ? people_with_guess_count[:people].length : 0
  end

end
