class RootController < ApplicationController

  caches_page :index
  def index
    @latest = FlickrUpdate.latest
  end

  caches_page :about, :bookmarklet

end
