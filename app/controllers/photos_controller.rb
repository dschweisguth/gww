class PhotosController < ApplicationController

  caches_page :unfound
  def unfound
    @lasttime = FlickrUpdate.latest.created_at
    @photos = Photo.unfound_or_unconfirmed
  end

  caches_page :most_commented_on
  def most_commented_on
    @title = 'Found photos with the most comments by members while unfound'
    @column_heading = '# of comments by members while unfound'
    @photos = Photo.most_commented_on params[:page], 30
  end

  caches_page :most_questioned
  def most_questioned
    @title = 'Found photos with the most comments with question marks by members while unfound'
    @column_heading = '# of comments with ? by members while unfound'
    @photos = Photo.most_questioned params[:page], 30
    render :template => 'photos/most_commented_on'
  end

  # Not cached since the cached copy would have an incorrect .html extension
  def unfound_data
    @lasttime = FlickrUpdate.latest.created_at
    @photos = Photo.unfound_or_unconfirmed
    render :action => 'unfound_data.xml.builder', :layout => false
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
