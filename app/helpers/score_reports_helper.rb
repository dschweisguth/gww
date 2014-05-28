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
    {
      bronze: 'https://farm9.staticflickr.com/8332/8143796058_095478b380_o.gif',
      silver: 'https://farm9.staticflickr.com/8470/8143764201_c938bf6bea_o.gif',
      gold:   'https://farm9.staticflickr.com/8050/8143796020_85a314ced3_o.gif'
    }[star]
  end

end
