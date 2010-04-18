class RootController < ApplicationController

  caches_page :index
  def index
    @latest = FlickrUpdate.latest
  end

end
