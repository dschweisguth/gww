class ApplicationController < ActionController::Base
  def expire_cached_pages
    expire_page :controller => "index", :action => "index"
  end
end
