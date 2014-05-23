class Admin::PhotosController < ApplicationController
  include SinglePhotoMapSupport

  caches_page :unfound
  def unfound
    @photos = Photo.unfound_or_unconfirmed
  end

  caches_page :inaccessible
  def inaccessible
    @photos = Photo.inaccessible
  end

  caches_page :multipoint
  def multipoint
    @photos = Photo.multipoint
  end

  def edit
    @photo = Photo.find_with_associations params[:id].to_i
    if params[:update_from_flickr]
      FlickrUpdater.update_photo @photo
      PageCache.clear
    end
    @photo.comments.to_a
    set_config_to @photo
  end

  def change_game_status
    Photo.change_game_status params[:id], params[:commit]
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def add_selected_answer
    begin
      Comment.add_selected_answer params[:comment_id], params[:username]
    rescue Photo::AddAnswerError => e
      flash[:notice] = e.message
    end
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def add_entered_answer
    begin
      Photo.add_entered_answer params[:id].to_i, params[:username], params[:answer_text]
    rescue Photo::AddAnswerError => e
      flash[:notice] = e.message
    end
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def remove_revelation
    Comment.remove_revelation params[:comment_id]
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def remove_guess
    begin
      Comment.remove_guess params[:comment_id]
    rescue Comment::RemoveGuessError => e
      flash[:notice] = e.message
    end
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def update_from_flickr
    redirect_to_edit_path params[:id], update_from_flickr: true
  end

  def destroy
    Photo.find(params[:id]).destroy
    PageCache.clear
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  def edit_in_gww
    from = params[:from]
    if from =~ /^https?:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if photo
        redirect_to_edit_path photo, update_from_flickr: true
        return
      else
        message = "Sorry, Guess Where Watcher doesn't know anything about " +
	        "that photo. Perhaps it hasn't been added to Guess Where SF, " +
          "or perhaps GWW hasn't updated since it was added."
      end
    else
      message = "Hmmm, that's strange. #{from} isn't a Flickr photo page. " +
        "How did we get here?"
    end
    message += " If you like, you can <a href=\"#{from}\">go back where you came from</a>."
    flash[:general_error] = message
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  private def redirect_to_edit_path(id, options = {})
    redirect_to edit_admin_photo_path id, options
  end

end
