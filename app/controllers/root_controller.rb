class RootController < ApplicationController

  def index
    @latest = FlickrUpdate.latest
    @wheresies_years = ScoreReport.minimum(:created_at).getlocal.year .. Time.now.year
  end

  caches_page :about, :bookmarklet, :about_auto_mapping

end
