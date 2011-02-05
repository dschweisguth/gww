class Admin::GuessesController < ApplicationController

  caches_page :report
  def report
    @report_date = Time.now

    updates = FlickrUpdate.all :order => "id desc", :limit => 2

    @guesses = Guess.all_since updates[0]
    @guessers = @guesses.group_by { |guess| guess.person }.sort \
      do |x, y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @revelations = Revelation.all_since updates[0]
    @revealers =
      @revelations.group_by { | revelation| revelation.photo.person } \
      .sort { |x, y| x[0].username.downcase <=> y[0].username.downcase }

    @weekly_high_scorers = Person.high_scorers 7
    @monthly_high_scorers = Person.high_scorers 30

    @new_photos_count = Photo.count_since updates[1]
    @unfound_count = Photo.unfound_or_unconfirmed_count

    people = Person.all
    @people_by_score = Person.by_score people

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
