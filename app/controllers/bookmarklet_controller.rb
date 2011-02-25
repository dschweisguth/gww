class BookmarkletController < ApplicationController

  def view
    @from = params[:from]
    if @from =~ /^http:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if photo
        redirect_to show_photo_path photo
        return
      else
        @message = "Sorry, Guess Where Watcher doesn't know anything about " +
	  "that photo. Perhaps it hasn't been added to Guess Where SF, " +
          "or perhaps GWW hasn't updated since it was added."
      end
    elsif @from =~ /^http:\/\/www.flickr.com\/(?:people|photos)\/([^\/]+)/
      flickrid = Regexp.last_match[1]
      # The URL might have the person's Flickr ID or their custom URL. We don't
      # know their custom URL, but see if it's the same as their username.
      person = Person.find_by_flickrid(flickrid) || Person.find_by_username(flickrid)
      if person
        redirect_to show_person_path person
        return
      else
        @message = "Sorry, Guess Where Watcher doesn't know anything about " +
	  "that person. Perhaps they haven't posted or guessed in Guess Where SF, " +
          "or perhaps GWW hasn't updated since they did."
      end
    else
      @message = "Hmmm, that's strange. #{@from} isn't a Flickr photo or person page. " +
        "How did we get here?"
    end
    render :file => 'shared/in_gww'
  end

end
