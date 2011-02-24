class RootController < ApplicationController
  auto_complete_for :person, :username

  def index
    @latest = FlickrUpdate.latest
  end

  caches_page :about, :bookmarklet

end
