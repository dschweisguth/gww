module ApplicationHelper

  IRREGULAR_PLURAL_VERBS = { 'were' => 'was', 'have' => 'has' }

  def singularize(verb, number)
    if number != 1
      return verb
    end
    singular = IRREGULAR_PLURAL_VERBS[verb]
    if ! singular.nil?
      return singular
    end
    verb + 's'
  end

  def ordinal(number)
    case number.to_s
      when /^1.$/
        suffix = 'th'
      when /1$/
        suffix = 'st'
      when /2$/
        suffix = 'nd'
      when /3$/
        suffix = 'rd'
      else
        suffix = 'th'
    end
    number.to_s + suffix
  end

  def local_date(datetime)
    datetime.getlocal.strftime '%Y/%m/%d'
  end

  def link_to_person(person)
    link_to h(person.username), show_person_path(person)
  end

  def link_to_photo(photo)
    link_to 'GWW', show_photo_path(photo)
  end

  def url_for_flickr_photo(photo)
    "http://www.flickr.com/photos/#{photo.person.flickrid}/#{photo.flickrid}/in/pool-guesswheresf/";
  end

  def link_to_flickr_photo(photo)
    link_to 'Flickr', url_for_flickr_photo(photo)
  end

  def url_for_flickr_image(photo, size)
    "http://#{ "farm#{photo.farm}." if ! photo.farm.empty? }static.flickr.com/#{photo.server}/#{photo.flickrid}_#{photo.secret}#{ '_' + size if ! size.nil? }.jpg"
  end

  def titled_image_tag(src, alt_and_title, options = {})
    image_tag src,
      { :alt => alt_and_title, :title => alt_and_title }.merge(options)
  end

  def thumbnail(photo, alt = "")
    link_to titled_image_tag(url_for_flickr_image(photo, 't'), alt), show_photo_path(photo)
  end

  def sandwich(breadcrumbs = 'shared/breadcrumbs', &content)
    render :layout => 'shared/sandwich', :locals => { :breadcrumbs => breadcrumbs }, &content
  end

end
