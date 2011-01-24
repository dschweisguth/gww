class ApplicationController < ActionController::Base

  def expire_cached_pages
    cache_dir = RAILS_ROOT + "/public/cache"
    if File.exist? cache_dir
      FileUtils.rm_r cache_dir
    end
  end

  def group_by_owner(items, attr, &owners_of)
    items.each_with_object [] do |item, groups|
      owners = owners_of.call item
      if ! owners.is_a? Array
        owners = [ owners ]
      end
      owners.each do |owner|
	if ! groups.include? owner
	  groups.push owner
	  owner[attr] = []
	end
	owner[attr].push item
      end
    end
  end
  protected :group_by_owner

  def in_gww(controller, action)
    @from = params[:from]
    if @from =~ /^http:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if ! photo.nil?
        redirect_to :controller => controller, :action => action, :id => photo
        return
      else
        @message = "Sorry, Guess Where Watcher doesn't know anything about " +
	  "that photo. Perhaps it hasn't been added to Guess Where SF, " +
          "or perhaps GWW hasn't updated since it was added."
      end
    else
      @message = "Hmmm, that's strange. #{@from} isn't a Flickr photo page. " +
        "How did we get here?"
    end
    render :file => 'application/in_gww'
  end

end
