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

end
