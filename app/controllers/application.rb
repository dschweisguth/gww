class ApplicationController < ActionController::Base

  def expire_cached_pages
    FileUtils.rm_r RAILS_ROOT + "/public/cache"
  end

end
