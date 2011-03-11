class Admin::ScoreReportsController < ApplicationController
  include ScoreReportsControllerSupport
  
  caches_page :index
  def index
    @score_reports = ScoreReport.all :order => 'id desc'
    @guess_counts = ScoreReport.guess_counts
    @revelation_counts = ScoreReport.revelation_counts
  end

  def new
    @flickr_html = CGI.escapeHTML prepare_gww_html Time.now
  end

  def create
    previous = ScoreReport.first :order => 'id desc'
    ScoreReport.create! :previous_report => previous
    PageCache.clear
    redirect_to admin_score_reports_path
  end

  def destroy
    ScoreReport.destroy params[:id]
    PageCache.clear
    redirect_to admin_score_reports_path
  end

end
