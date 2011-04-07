class RootController < ApplicationController
  autocomplete :person, :username

  def index
    @latest = FlickrUpdate.latest
    @wheresies_years = ScoreReport.order(:created_at).first.created_at.getlocal.year .. Time.now.year
  end

  caches_page :about, :bookmarklet

end
