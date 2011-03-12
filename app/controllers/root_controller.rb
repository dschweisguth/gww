class RootController < ApplicationController
  auto_complete_for :person, :username

  def index
    @latest = FlickrUpdate.latest
    @wheresies_years = ScoreReport.first(:order => 'created_at').created_at.getlocal.year .. Time.now.year
  end

  caches_page :about, :bookmarklet

end
