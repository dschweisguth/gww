module ScoreReportsControllerSupport
  private def prepare_gww_thumbnails_html(report_date)
    @report_date = report_date.getlocal

    previous_report = ScoreReport.previous @report_date
    previous_report_date = previous_report ? previous_report.created_at : Time.utc(2005)

    @guesses = ScoreReportsGuess.all_between previous_report_date, @report_date
    @guessers = ScoreReportsPerson.sort_by_photo_count_and_username @guesses.group_by(&:person)

    @revelations = ScoreReportsRevelation.all_between previous_report_date, @report_date
    @revealers =
      @revelations.group_by { |revelation| revelation.photo.person }.
        sort { |x, y| x[0].username.downcase <=> y[0].username.downcase }

    people, people_by_score = people_by_score report_date
    ScoreReportsPerson.add_change_in_standings people_by_score, people, previous_report_date, @guessers

    raw_html = render_to_string(partial: 'score_reports/raw_thumbnails').chomp
    @gww_thumbnails_html = raw_html.gsub /$/, '<br/>'
    raw_html

  end

  private def prepare_gww_stats_html(report_date)
    report_date = report_date.getlocal

    previous_report = ScoreReport.previous report_date
    previous_report_date = previous_report ? previous_report.created_at : Time.utc(2005)

    @weekly_high_scorers = ScoreReportsPerson.high_scorers report_date, 7
    @monthly_high_scorers = ScoreReportsPerson.high_scorers report_date, 30

    @weekly_top_posters = ScoreReportsPerson.top_posters report_date, 7
    @monthly_top_posters = ScoreReportsPerson.top_posters report_date, 30

    @new_photos_count = ScoreReportsPhoto.count_between previous_report_date, report_date
    @unfound_count = ScoreReportsPhoto.unfound_or_unconfirmed_count_before report_date

    people, @people_by_score = people_by_score report_date

    @total_participants = people.length
    @total_posters_only = @people_by_score[0].nil? ? 0 : @people_by_score[0].length
    @total_correct_guessers = @total_participants - @total_posters_only
    @member_count = FlickrUpdate.latest.member_count
    @total_single_guessers = @people_by_score[1].nil? ? 0 : @people_by_score[1].length

    raw_html = render_to_string(partial: 'score_reports/raw_stats').chomp
    @gww_stats_html = raw_html.gsub /$/, '<br/>'
    raw_html

  end

  private def people_by_score(report_date)
    people = ScoreReportsPerson.all_before report_date
    ScoreReportsPhoto.add_posts people, report_date, :post_count
    people_by_score = ScoreReportsPerson.by_score people, report_date
    return people, people_by_score
  end

end
