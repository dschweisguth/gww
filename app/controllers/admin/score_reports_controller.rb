class Admin::ScoreReportsController < ApplicationController

  def index
    @score_reports = ScoreReport.all :order => 'id desc'
  end

  def new
    @report_date = Time.now
    utc_report_date = @report_date.getutc

    previous_report = ScoreReport.first \
      :conditions => [ 'created_at < ?', @report_date ], :order => 'id desc'
    previous_report_date = previous_report.created_at
    @guesses = Guess.all_between previous_report_date, utc_report_date
    @guessers = @guesses.group_by { |guess| guess.person }.sort \
      do |x, y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @revelations = Revelation.all_between previous_report_date, utc_report_date
    @revealers =
      @revelations.group_by { | revelation| revelation.photo.person } \
      .sort { |x, y| x[0].username.downcase <=> y[0].username.downcase }

    @weekly_high_scorers = Person.high_scorers 7
    @monthly_high_scorers = Person.high_scorers 30

    @new_photos_count = Photo.count_between previous_report_date, utc_report_date
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
    redirect_to new_score_report_path
  end

  def destroy
    ScoreReport.destroy params[:id]
    redirect_to score_reports_path
  end

end
