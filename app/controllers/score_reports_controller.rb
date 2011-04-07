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
    prepare_gww_html ScoreReport.find(params[:id]).created_at
  end

end
