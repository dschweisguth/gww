class Admin::PhotosController < ApplicationController
  auto_complete_for :person, :username

  def update
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    new_photo_count, new_person_count, pages_gotten, pages_available =
      Photo.update_all_from_flickr
    PageCache.clear
    flash[:notice] = "Created #{new_photo_count} new photos and " +
      "#{new_person_count} new users. Got #{pages_gotten} pages out of " +
      "#{pages_available}.</br>"
    redirect_to admin_root_path
  end

  def update_statistics
    Photo.update_statistics
    PageCache.clear
    flash[:notice] = 'Updated statistics.</br>'
    redirect_to admin_root_path
  end

  caches_page :unfound
  def unfound
    @photos = Photo.unfound_or_unconfirmed
  end

  caches_page :inaccessible
  def inaccessible
    @photos = Photo.all \
      :conditions =>
        [ "seen_at < ? AND game_status in ('unfound', 'unconfirmed')",
          FlickrUpdate.latest.created_at ],
      :include => :person, :order => "lastupdate desc"
  end

  caches_page :multipoint
  def multipoint
    @photos = Photo.multipoint
  end

  #noinspection RailsParamDefResolve
  def edit
    @photo = Photo.find params[:id],
      :include => [ :person, :revelation, { :guesses => :person } ]
    if params[:nocomment]
      @comments = Comment.find_all_by_photo_id(@photo)
    else
      @comments = @photo.load_comments
      PageCache.clear
    end
  end

  def change_game_status
    Photo.change_game_status params[:id], params[:commit]
    PageCache.clear
    redirect_to edit_photo_path :id => params[:id], :nocomment => 'true'
  end

  def update_answer
    photo_id = params[:id]
    comment = params[:comment]
    if comment.nil?
      flash[:notice] = 'Please select a comment before adding or removing a guess or revelation.'
      redirect_to edit_photo_path :id => photo_id, :nocomment => 'true'
      return
    end
    comment_id = comment[:id]
    if params[:commit] == 'Add this guess or revelation'
      Photo.add_answer comment_id, params[:person][:username]
    else
      begin
        Photo.remove_answer comment_id
      rescue Photo::RemoveAnswerError => e
        flash[:notice] = e.message
      end
    end
    PageCache.clear
    redirect_to edit_photo_path :id => photo_id, :nocomment => 'true'
  end

  def reload_comments
    redirect_to edit_photo_path :id => params[:id]
  end

  def destroy
    Photo.destroy_photo_and_dependent_objects params[:id]
    PageCache.clear
    redirect_to admin_root_path
  end

  def edit_in_gww
    in_gww 'admin/photos', 'edit'
  end

end
