class Admin::ScoreReportsController < ApplicationController
  include ScoreReportsControllerSupport
  
  caches_page :index
  def index
    @score_reports = ScoreReport.all :order => 'id desc'
  end

  def new
    prepare_gww_html Time.now
    @flickr_html = CGI.escapeHTML render_to_string :partial => 'score_reports/topic_content'
  end

  def create
    ScoreReport.create!
    PageCache.clear
    redirect_to admin_score_reports_path
  end

  def destroy
    ScoreReport.destroy params[:id]
    PageCache.clear
    redirect_to admin_score_reports_path
  end

end
