class Admin::PhotosController < ApplicationController
  autocomplete :person, :username

  def update_all_from_flickr
    # Expire before updating so everyone sees the in-progress message
    PageCache.clear
    new_photo_count, new_person_count, pages_gotten, pages_available =
      Photo.update_all_from_flickr
    PageCache.clear
    flash[:notice] = "Created #{new_photo_count} new photos and " +
      "#{new_person_count} new users. Got #{pages_gotten} pages out of " +
      "#{pages_available}."
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  def update_statistics
    Photo.update_statistics
    PageCache.clear
    flash[:notice] = 'Updated statistics.'
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

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

  #noinspection RailsParamDefResolve
  def edit
    @photo = Photo.find params[:id],
      :include => [ :person, :revelation, { :guesses => :person } ]
    if params[:load_comments]
      @comments = @photo.load_comments
      PageCache.clear
    else
      @comments = Comment.find_all_by_photo_id(@photo)
    end
    @comments.each { |comment| comment.photo = @photo }
  end

  def change_game_status
    Photo.change_game_status params[:id], params[:commit]
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def add_selected_answer
    begin
      Comment.add_selected_answer params[:comment_id], params[:username]
    rescue Comment::AddAnswerError => e
      flash[:notice] = e.message
    end
    PageCache.clear
    redirect_to_edit_path params[:id]
  end

  def add_entered_answer
    begin
      Comment.add_entered_answer params[:id].to_i, params[:username], params[:answer_text]
    rescue Comment::AddAnswerError => e
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

  def reload_comments
    redirect_to_edit_path params[:id], :load_comments => true
  end

  def destroy
    Photo.destroy_photo_and_dependent_objects params[:id]
    PageCache.clear
    #noinspection RubyResolve
    redirect_to admin_root_path
  end

  def edit_in_gww
    from = params[:from]
    if from =~ /^http:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if photo
        redirect_to_edit_path photo, :load_comments => true
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

  def redirect_to_edit_path(id, options = {})
    #noinspection RubyResolve
    redirect_to edit_admin_photo_path id, options
  end
  private :redirect_to_edit_path

end
