class BookmarkletController < ApplicationController

  def show
    from = params[:from]
    path = root_path
    message = nil
    if from =~ /^https?:\/\/www.flickr.com\/photos\/[^\/]+\/(\d+)/
      flickrid = Regexp.last_match[1]
      photo = Photo.find_by_flickrid flickrid
      if photo
        path = photo_path photo
      else
        message = "Sorry, Guess Where Watcher doesn't know anything about " +
	        "that photo. Perhaps it hasn't been added to Guess Where SF, " +
          "or perhaps GWW hasn't updated since it was added. " +
          "If you like, you can <a href=\"#{from}\">go back where you came from</a>."
      end
    elsif from =~ /^https?:\/\/www.flickr.com\/(?:people|photos)\/([^\/]+)/
      person_identifier = Regexp.last_match[1]
      person = Person.find_by_pathalias(person_identifier) || Person.find_by_flickrid(person_identifier)
      if person
        # noinspection RubyResolve
        path = person_path person
      else
        message = "Sorry, Guess Where Watcher doesn't know anything about that person. " +
          "It might be that their custom URL is different than their username. " +
          "Or perhaps they haven't posted or guessed in Guess Where SF, or GWW hasn't updated since they did. " +
          "If you like, you can search for them using the box below, or <a href=\"#{from}\">go back where you came from</a>."
      end
    else
      message = "Hmmm, that's strange. #{from} isn't a Flickr photo or person page. " +
        "How did we get here? If you like, you can <a href=\"#{from}\">go back where you came from</a>."
    end
    flash[:general_error] = message
    redirect_to path
  end

end
