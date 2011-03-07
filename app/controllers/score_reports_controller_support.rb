require 'fixnum'

module ScoreReportsControllerSupport

  # TODO Dave add welcomes to new members
  def prepare_gww_html(report_date)
    @report_date = report_date.getlocal

    previous_report = ScoreReport.previous @report_date
    previous_report_date = previous_report ? previous_report.created_at : Time.utc(2005)

    @guesses = Guess.all_between previous_report_date, @report_date
    @guessers = @guesses.group_by { |guess| guess.person }.sort \
      do |x, y|
        c = y[1].length <=> x[1].length
        c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
      end

    @revelations = Revelation.all_between previous_report_date, @report_date
    @revealers =
      @revelations.group_by { | revelation| revelation.photo.person } \
      .sort { |x, y| x[0].username.downcase <=> y[0].username.downcase }

    @weekly_high_scorers = Person.high_scorers @report_date, 7
    @monthly_high_scorers = Person.high_scorers @report_date, 30

    @new_photos_count = Photo.count_between previous_report_date, @report_date
    @unfound_count = Photo.unfound_or_unconfirmed_count_before @report_date

    people = Person.all_before @report_date
    Photo.add_posts people, @report_date
    @people_by_score = Person.by_score people, @report_date
    Person.add_changes_in_standings @people_by_score, people, previous_report_date, @guessers

    @total_participants = people.length
    @total_posters_only = @people_by_score[0].nil? ? 0 : @people_by_score[0].length
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = FlickrUpdate.first(:order => 'id desc').member_count
    @total_single_guessers = @people_by_score[1].nil? ? 1 : @people_by_score[1].length

    @gww_html = render_to_string(:partial => 'score_reports/topic_content').gsub /$/, '<br/>'

  end
  private :prepare_gww_html

end
