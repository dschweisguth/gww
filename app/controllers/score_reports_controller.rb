class ScoreReportsController < ApplicationController

  caches_page :index
  def index
    @score_reports = ScoreReport.all :order => 'id desc'
  end

end
