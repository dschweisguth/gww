class LocationParser
  
  def initialize(known_street_names)
    @known_street_names = known_street_names
    @known_street_names = @known_street_names.select { |name| name !~ /^UNNAMED / }
    street_name_regexp = "[A-Za-z0-9']+"
    @regexp = /(#{street_name_regexp})\s*and\s*(#{street_name_regexp})/
  end

  def parse(comment)
    if comment =~ @regexp
      Location.make_valid Regexp.last_match(1), Regexp.last_match(2)
    else
      Location.make_invalid
    end
  end

end
