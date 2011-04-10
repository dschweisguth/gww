class LocationParser

  UNWANTED_STREET_NAMES = [
    /^\d\d(RD|TH) TI/,
    /^ALEMANY BLVD OFF/,
    /^BAY SHORE BLVD (ON|OFF)/,
    /^CESAR CHAVEZ ON/,
    /^FORT MASON /,
    /^FORT MILEY /,
    /^HWY 1/, # excludes both HWY 1 and HWY 101
    /^I-280/,
    /^I-80/,
    /^INDUSTRIAL ST (ON|OFF)/,
    /^JUNIPERO SERRA\s+BLVD (ON|OFF)/,
    /^UNNAMED/
  ]
  
  def initialize(known_street_names)
    street_name_regexp = "[A-Za-z0-9']+"
    known_street_names.each do |name|
      next if UNWANTED_STREET_NAMES.any? { |unwanted| name =~ unwanted }
      if name.include? ' '
        street_name_regexp = "(?:#{name})|" + street_name_regexp
      end
    end
    @regexp = /(#{street_name_regexp})\s*and\s*(#{street_name_regexp})/i
  end

  def parse(comment)
    if comment =~ @regexp
      [ Location.new Regexp.last_match(1), Regexp.last_match(2) ]
    else
      []
    end
  end

end
