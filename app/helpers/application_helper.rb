module ApplicationHelper
  include Photos

  IRREGULAR_PLURAL_VERBS = {
    'are' => 'is',
    'were' => 'was',
    'have' => 'has'
  }

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

  def local_date(datetime)
    datetime.getlocal.strftime '%Y/%m/%d'
  end

  def link_to_person(person)
    link_to h(person.username), person_path(person)
  end

  def link_to_photo(photo)
    link_to 'GWW', photo_path(photo)
  end

  def link_to_flickr_photo(photo)
    link_to 'Flickr', url_for_flickr_photo(photo)
  end

  def titled_image_tag(src, alt_and_title, options = {})
    image_tag src,
      { :alt => alt_and_title, :title => alt_and_title }.merge(options)
  end

  def thumbnail(photo, alt = "")
    link_to titled_image_tag(url_for_flickr_image(photo, 't'), alt), photo_path(photo)
  end

  def sandwich(breadcrumbs = 'shared/breadcrumbs', &content)
    render :layout => 'shared/sandwich', :locals => { :breadcrumbs => breadcrumbs }, &content
  end

  def head_css(*stylesheets)
    content_for :head do
      stylesheet_link_tag(stylesheets) + "\n"
    end
  end

  def head_javascript(*custom)
    content_for :head do
      javascript_include_tag(:defaults, *custom) + "\n" +
      csrf_meta_tag
    end
  end

end
