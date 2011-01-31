module Admin::GuessesHelper

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

  # This overrides the version in ApplicationHelper
  def link_to_person(person)
    link_to h(escape_username(person.username)), show_person_url(person)
  end

  def image_for_star(star)
    path_to_url \
      case star
      when :bronze
	'/images/star-padded-bronze.gif'
      when :silver
	'/images/star-padded-silver.gif'
      when :gold
	'/images/star-padded-gold-animated.gif'
      end
  end

  def path_to_url(path)
    request.protocol + request.host_with_port + path
  end
  private :path_to_url

end
