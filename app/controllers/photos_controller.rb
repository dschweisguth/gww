class PhotosController < ApplicationController

  caches_page :unfound_pretty
  def unfound_pretty
    @lasttime = FlickrUpdate.latest.created_at
    @photos = unfound_or_unconfirmed_photos
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.latest.created_at
    @photos = unfound_or_unconfirmed_photos
    render :action => 'unfound_data.xml.builder', :layout => false
  end

  def unfound_or_unconfirmed_photos
    Photo.find :all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc"
  end

  caches_page :show
  def show
    @photo = Photo.find params[:id],
      :include => [ :person, :revelation, { :guesses => :person } ]
    @comments = Comment.find_all_by_photo_id @photo
  end

  def view_in_gww
    in_gww 'show'
  end

  def edit_in_gww
    in_gww 'edit'
  end

  def in_gww(action)
    @from = params[:from]
    if @from =~ /^http:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if ! photo.nil?
        redirect_to :action => action, :id => photo
      else
        @message = "Sorry, Guess Where Watcher doesn't know anything about " +
	  "that photo. Perhaps it hasn't been added to Guess Where SF, " +
          "or perhaps GWW hasn't updated since it was added."
      end
    else
      @message = "Hmmm, that's strange. #{@from} isn't a Flickr photo page. " +
        "How did we get here?"
    end
    render :action => 'in_gww'
  end

end
