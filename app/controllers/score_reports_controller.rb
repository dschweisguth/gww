class ScoreReportsController < ApplicationController
  include ScoreReportsControllerSupport

  caches_page :index
  def index
    @score_reports = ScoreReport.all :order => 'id desc'
  end

  caches_page :show
  def show
    prepare_gww_html ScoreReport.find(params[:id]).created_at
  end

end
