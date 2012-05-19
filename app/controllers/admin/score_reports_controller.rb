class Admin::ScoreReportsController < ApplicationController
  include ScoreReportsControllerSupport
  
  caches_page :index
  def index
    @score_reports = ScoreReport.order('id desc')
    @guess_counts = ScoreReport.guess_counts
    @revelation_counts = ScoreReport.revelation_counts
  end

  def new
    now = Time.now
    @flickr_thumbnails_html = CGI.escapeHTML prepare_gww_thumbnails_html now
    @flickr_stats_html = CGI.escapeHTML prepare_gww_stats_html now
  end

  def create
    previous = ScoreReport.order('id desc').first
    ScoreReport.create! :previous_report => previous
    PageCache.clear
    redirect_to admin_score_reports_path
  end

  def destroy
    #noinspection RubyArgCount
    ScoreReport.destroy params[:id]
    PageCache.clear
    redirect_to admin_score_reports_path
  end

end
