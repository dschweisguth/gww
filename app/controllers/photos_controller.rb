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
    in_gww 'photos', 'show'
  end

end
