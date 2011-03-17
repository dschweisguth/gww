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
      "#{pages_available}."
    redirect_to admin_root_path
  end

  def update_statistics
    Photo.update_statistics
    PageCache.clear
    flash[:notice] = 'Updated statistics.'
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
      Photo.old_add_answer comment_id, params[:person][:username]
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

  def add_answer
    comment_id = params[:id]
    #noinspection RailsParamDefResolve
    comment = Comment.find comment_id, :include => { :photo => :revelation }
    photo = comment.photo

    username = params[:username]
    if username.empty?
      guesser_flickrid = comment.flickrid
      guesser_username = comment.username
    else
      # Note that this branch results in a guess that can't be individually removed
      guesser_flickrid = Comment.find_by_username(username).flickrid
      guesser_username = username
    end
    Photo.transaction do
      if guesser_flickrid == photo.person.flickrid
        photo.game_status = 'revealed'
        photo.save!

        revelation = photo.revelation
        if revelation
          revelation.revelation_text = comment.comment_text
          revelation.revealed_at = comment.commented_at
          # TODO Dave update added_at
          revelation.save!
        else
          Revelation.create! \
            :photo => photo,
            :revelation_text => comment.comment_text,
            :revealed_at => comment.commented_at,
            :added_at => Time.now.getutc
        end

        Guess.destroy_all_by_photo_id photo.id

      else
        photo.game_status = 'found'
        photo.save!

        guesser = Person.find_by_flickrid guesser_flickrid
        if guesser
          guess = Guess.find_by_photo_id_and_person_id photo.id, guesser.id
        else
          guesser = Person.create! \
            :flickrid => guesser_flickrid,
            :username => guesser_username
          guess = nil
        end
        if guess
          guess.guessed_at = comment.commented_at
          guess.guess_text = comment.comment_text
          # TODO Dave update added_at
          guess.save!
        else
          Guess.create! \
            :photo => photo,
            :person => guesser,
            :guess_text => comment.comment_text,
            :guessed_at => comment.commented_at,
            :added_at => Time.now.getutc
        end

        photo.revelation.destroy if photo.revelation

      end
    end

    PageCache.clear
    redirect_to edit_photo_path :id => photo.id, :nocomment => 'true'
  end

  def remove_revelation
    comment_id = params[:id]
    #noinspection RailsParamDefResolve
    comment = Comment.find comment_id, :include => { :photo => :revelation }
    comment.photo.destroy_revelation
    PageCache.clear
    redirect_to edit_photo_path :id => comment.photo_id, :nocomment => 'true'
  end

  def remove_guess
    comment_id = params[:id]
    comment = Comment.find comment_id, :include => :photo
    Photo.transaction do
      guesser = Person.find_by_flickrid comment.flickrid
      guess = Guess.find_by_person_id_and_guess_text guesser.id, comment.comment_text[0, 255]
      guess.destroy
      comment.photo.update_game_status_after_removing_guess
    end
    PageCache.clear
    redirect_to edit_photo_path :id => comment.photo_id, :nocomment => 'true'
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
    @from = params[:from]
    if @from =~ /^http:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if photo
        redirect_to edit_photo_path photo
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
    render :file => 'shared/in_gww'
  end

end
