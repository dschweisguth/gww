class Admin::GuessesController < ApplicationController

  caches_page :report
  #noinspection RailsParamDefResolve
  def report
    @report_date = Time.now

    updates = FlickrUpdate.all :order => "id desc", :limit => 2

    @guesses = Guess.all \
      :conditions => [ "added_at > ?", updates[0].created_at ],
      :include => [ { :photo => :person }, :person ], :order => "guessed_at"
    @guessers = group_by_owner(@guesses, :guesses) { |guess| guess.person } 
    @guessers.sort! { |x, y|
      c = y[:guesses].length <=> x[:guesses].length
      c != 0 ? c : x.username.downcase <=> y.username.downcase }

    @revelations = Revelation.all \
      :conditions => [ "added_at > ?", updates[0].created_at ], 
      :include => { :photo => :person }
    @revealers = group_by_owner(@revelations, :revelations) \
      { |revelation| revelation.photo.person }
    @revealers.sort! { |x, y| x.username.downcase <=> y.username.downcase }

    @weekly_high_scorers = Person.high_scorers 7
    @monthly_high_scorers = Person.high_scorers 30

    @new_photos_count =
      Photo.count :conditions => [ "dateadded > ?", updates[1].created_at ]
    @unfound_count = Photo.unfound_or_unconfirmed_count
    
    people = Person.all
    scores = Guess.count :group => :person_id
    posts_per_person = Photo.count :group => :person_id
    @people_by_score = []
    people.each do |person|
      score = scores[person.id] || 0
      people_with_score = @people_by_score.find { |x| x[:score] == score }
      if ! people_with_score
        people_with_score = { :score => score, :people => [] }
        @people_by_score.push people_with_score
      end
      people_with_score[:people].push person
      person[:posts] = posts_per_person[person.id] || 0
    end
    @people_by_score.sort! { |x, y| y[:score] <=> x[:score] }

    @total_participants = people.length
    @total_posters_only = people_with @people_by_score, 0
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = updates[0].member_count
    @total_single_guessers = people_with @people_by_score, 1

    @html = CGI.escapeHTML \
      render_to_string :partial => 'admin/guesses/report/topic_content'
    @topic_content =
      render_to_string(:partial => 'admin/guesses/report/topic_content') \
        .gsub /$/, '<br/>'

  end

  def people_with(people_by_score, score)
    people_with_score = people_by_score.find { |x| x[:score] == score }
    people_with_score ? people_with_score[:people].length : 0
  end
  private :people_with

end
