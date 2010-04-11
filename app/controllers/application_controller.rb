class ApplicationController < ActionController::Base

  def expire_cached_pages
    cache_dir = RAILS_ROOT + "/public/cache"
    if File.exist? cache_dir
      FileUtils.rm_r cache_dir
    end
  end

end
