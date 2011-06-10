class ScoreReportsController < ApplicationController
  include ScoreReportsControllerSupport

  caches_page :index
  def index
    @score_reports = ScoreReport.order('id desc')
    @guess_counts = ScoreReport.guess_counts
    @revelation_counts = ScoreReport.revelation_counts
  end

  caches_page :show
  def show
    report_date = ScoreReport.find(params[:id]).created_at
    prepare_gww_thumbnails_html report_date
    prepare_gww_stats_html report_date
  end

end
