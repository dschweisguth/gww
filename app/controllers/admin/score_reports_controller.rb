class Admin::ScoreReportsController < ApplicationController

  # TODO Dave test
  def index
    @score_reports = ScoreReport.all :order => 'id desc'
  end

  def new
    @report_date = Time.now

    previous_report = ScoreReport.first :order => 'id desc'

    @guesses = Guess.all_since previous_report
    @guessers = @guesses.group_by { |guess| guess.person }.sort \
      do |x, y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @revelations = Revelation.all_since previous_report
    @revealers =
      @revelations.group_by { | revelation| revelation.photo.person } \
      .sort { |x, y| x[0].username.downcase <=> y[0].username.downcase }

    @weekly_high_scorers = Person.high_scorers 7
    @monthly_high_scorers = Person.high_scorers 30

    @new_photos_count = Photo.count_since previous_report
    @unfound_count = Photo.unfound_or_unconfirmed_count

    people = Person.all
    Photo.add_posts people
    @people_by_score = Person.by_score people

    @total_participants = people.length
    @total_posters_only = @people_by_score[0].nil? ? 0 : @people_by_score[0].length
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = FlickrUpdate.first(:order => 'id desc').member_count
    @total_single_guessers = @people_by_score[1].nil? ? 1 : @people_by_score[1].length

    @html = CGI.escapeHTML \
      render_to_string :partial => 'admin/score_reports/new/topic_content'
    @topic_content =
      render_to_string(:partial => 'admin/score_reports/new/topic_content') \
        .gsub /$/, '<br/>'

  end

  def create
    ScoreReport.create!
    redirect_to :controller => 'admin/score_reports', :action => 'new'
  end

  def destroy
    ScoreReport.destroy params[:id]
    redirect_to score_reports_path
  end

end
