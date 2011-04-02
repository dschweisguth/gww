class PageCache
  def self.clear
    cache_dir = Rails.root.to_s + "/public/cache"
    if File.exist? cache_dir
      FileUtils.rm_r cache_dir
    end
  end
end
