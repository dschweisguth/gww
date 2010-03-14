class ApplicationController < ActionController::Base

  CACHED_PAGES = {
    :index => [ :index ]
  }

  def expire_cached_pages
    CACHED_PAGES.each do |controller, actions|
      actions.each do |action|
        expire_page :controller => controller.to_s, :action => action.to_s
      end
    end
  end

end
