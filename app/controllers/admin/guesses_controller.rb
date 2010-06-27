class Admin::GuessesController < ApplicationController

  caches_page :report
  def report
    @report_date = Time.now

    updates = FlickrUpdate.find :all, :order => "id desc", :limit => 2

    @guesses = Guess.find :all,
      :conditions => [ "added_at > ?", updates[0].created_at ],
      :include => [ { :photo => :person }, :person ]
    @guessers = group_by_owner(@guesses, :guesses) { |guess| guess.person } 
    @guessers.sort! { |x, y|
      c = y[:guesses].length <=> x[:guesses].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase }

    @new_photos_count = Photo.count :all,
      :conditions => [ "dateadded > ?", updates[1].created_at ]
    @unfound_count = Photo.count :all,
      :conditions => "game_status in ('unfound', 'unconfirmed')";
    
    people = Person.find :all
    @posts_per_person = Photo.count :all, :group => :person_id
    scores = Guess.count :all, :group => :person_id
    @people_by_score = []
    people.each do |person|
      score = scores[person.id] || 0
      people_with_score = @people_by_score.find { |x| x[:score] == score }
      if ! people_with_score
        people_with_score = { :score => score, :people => [] }
        @people_by_score.push people_with_score
      end
      people_with_score[:people].push person
    end
    @people_by_score.sort! { |x, y| y[:score] <=> x[:score] }

    @weekly_high_scorers = Person.high_scorers 7
    @monthly_high_scorers = Person.high_scorers 30

    @revelations = Revelation.find :all,
      :conditions => [ "added_at > ?", updates[0].created_at ], 
      :include => { :photo => :person }
    @revealers = group_by_owner @revelations, :revelations do |revelation|
      revelation.photo.person
    end
    @revealers.sort! { |x, y| x.username.downcase <=> y.username.downcase }

    @total_participants = people.length
    @total_posters_only = people_with @people_by_score, 0
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = updates[0].member_count
    @total_single_guessers = people_with @people_by_score, 1

  end

  def group_by_owner(items, attr, &owner_of)
    groups = []
    items.each do |item|
      owner = owner_of.call item
      if ! groups.include? owner
        groups.push owner
        owner[attr] = []
      end
      owner[attr].push item
    end
    groups
  end

  def people_with(people_by_score, score)
    people_with_score = people_by_score.find { |x| x[:score] == score }
    people_with_score ? people_with_score[:people].length : 0
  end

end
