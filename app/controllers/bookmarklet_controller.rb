class BookmarkletController < ApplicationController
  def show
    from = params[:from]
    if from =~ %r{^https?://www.flickr.com/photos/[^/]+/(\d+)}
      redirect_to_photo Regexp.last_match[1], from
    elsif from =~ %r{^https?://www.flickr.com/(?:people|photos)/([^/]+)}
      redirect_to_person Regexp.last_match[1], from
    else
      report_error "Hmmm, that's strange. #{from} isn't a Flickr photo or person page. " \
        "How did we get here? If you like, you can <a href=\"#{from}\">go back where you came from</a>."
    end
  end

  private

  def redirect_to_photo(flickrid, from)
    photo = Photo.find_by_flickrid flickrid
    if photo
      redirect_to photo_path photo
    else
      report_error "Sorry, Guess Where Watcher doesn't know anything about " \
        "that photo. Perhaps it hasn't been added to Guess Where SF, " \
        "or perhaps GWW hasn't updated since it was added. " \
        "If you like, you can <a href=\"#{from}\">go back where you came from</a>."
    end
  end

  def redirect_to_person(person_identifier, from)
    person = Person.find_by_pathalias(person_identifier) || Person.find_by_flickrid(person_identifier)
    if person
      redirect_to person_path person
    else
      report_error "Sorry, Guess Where Watcher doesn't know anything about that person. " \
        "It might be that their custom URL is different than their username. " \
        "Or perhaps they haven't posted or guessed in Guess Where SF, or GWW hasn't updated since they did. " \
        "If you like, you can search for them using the box below, or <a href=\"#{from}\">go back where you came from</a>."
    end
  end

  def report_error(message)
    flash[:general_error] = message
    redirect_to root_path
  end
end
