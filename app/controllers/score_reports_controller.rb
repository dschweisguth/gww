class ScoreReportsController < ApplicationController
  include ScoreReportsControllerSupport

  caches_page :index
  def index
    @score_reports = ScoreReport.all :order => 'id desc'
    @guess_counts = Hash[ScoreReport.all_with_guess_counts.map { |report| [ report.id, report[:count] ] }]
    @revelation_counts = Hash[ScoreReport.all_with_revelation_counts.map { |report| [ report.id, report[:count] ] }]
  end

  caches_page :show
  def show
    prepare_gww_html ScoreReport.find(params[:id]).created_at
  end

end
