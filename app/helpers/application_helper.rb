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

  def local_date(datetime)
    datetime.getlocal.strftime '%Y/%m/%d'
  end

  def link_to_person(person)
    link_to person.username, show_person_url(person)
  end

end
