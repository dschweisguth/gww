module Admin::GuessesHelper

  # Flickr replaces link text that looks like a domain name with the URL to
  # deter spoofing, but the result is ugly. Slightly mangle usernames that look
  # like domain names to avoid this fate.
  def escape_username(username)
    if username =~ /^(.*?) ?\.(\w{3})$/
      Regexp.last_match[1] + ' . ' + Regexp.last_match[2]
    else
      username
    end
  end

  def years_old(guess)
    ((guess.guessed_at - guess.photo.dateadded).to_i /
      (365.24 * 24 * 60 * 60)).truncate
  end

  def star_image(guess)
    path =
      case years_old guess
      when 1
	'/images/star-padded-bronze.gif'
      when 2
	'/images/star-padded-silver.gif'
      else
	'/images/star-padded-gold-animated.gif'
      end
    path_to_url path
  end

  def path_to_url(path)
    request.protocol + request.host_with_port + path
  end
  private :path_to_url

end
