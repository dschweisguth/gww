module ScoreReportsHelper

  # Flickr replaces link text that looks like a domain name with the URL to
  # deter spoofing, but the result is ugly. Slightly mangle usernames that look
  # like domain names to avoid this fate.
  def escape_username(username)
    if username =~ /^(.*\w)\.(\w{2,})$/
      Regexp.last_match[1] + ' . ' + Regexp.last_match[2]
    else
      username
    end
  end

  def link_to_person_url(person)
    link_to h(escape_username(person.username)), person_url(person)
  end

  def image_url_for_star(star)
    star_images = {
      :bronze => '/images/star-padded-bronze.gif',
      :silver => '/images/star-padded-silver.gif',
      :gold => '/images/star-padded-gold-animated.gif'
    }
    path_to_url star_images[star]
  end

  def path_to_url(path)
    request.protocol + request.host_with_port + path
  end
  private :path_to_url

end
