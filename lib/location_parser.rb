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
    street_name_regexp = known_street_names.select { |name| name.include? ' ' } \
      .reject { |name| UNWANTED_STREET_NAMES.any? { |unwanted| name =~ unwanted } } \
      .map { |name| "(?:#{name})" }.join '|'
    if ! street_name_regexp.empty?
      street_name_regexp += '|'
    end
    street_name_regexp += "[A-Za-z0-9']+"
    @regexp = /(#{street_name_regexp})\s+(?:and|&amp;|at|@|by|near)\s+(#{street_name_regexp})/i
  end

  def parse(comment)
    comment = comment.strip
    locations = []
    while true
      match = @regexp.match comment
      break if ! match
      locations << Location.new(match[1], match[2])
      comment = comment[match.end(1) + 1, comment.length]
    end
    locations
  end

end
