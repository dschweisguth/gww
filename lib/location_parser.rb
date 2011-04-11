# TODO Dave handle street addresses
# TODO Dave handle "Vallejo and... Taylor"
# TODO Dave handle "looking onto", "looking towards"?
# TODO Dave handle "X end of Y"
# TODO Dave handle "just X of", "just past"
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
    street = known_street_names.select { |name| name.include? ' ' } \
      .reject { |name| UNWANTED_STREET_NAMES.any? { |unwanted| name =~ unwanted } } \
      .map { |name| "(?:#{name})" }.join '|'
    if ! street.empty?
      street += '|'
    end
    street = "(#{street}[A-Za-z0-9']+)((?:\\s+(?:#{Street::TYPES.join('|')})\\.?)?)"

    @regexps = [
      /#{street}\s+(?:between|bet\.)\s+#{street}\s+(?:and|&amp;)\s+#{street}/i,
      /#{street}\s+(?:and|&amp;|at|@|by|near)\s+#{street}/i
    ]
  end

  def parse(comment)
    locations = find_locations comment.strip
    locations.reject do |location|
      locations.find do |other|
        other.text != location.text && other.text.include?(location.text)
      end
    end
  end

  def find_locations(comment)
    @regexps.each_with_object([]) do |regexp, locations|
      remaining_comment = comment
      while true
        match = regexp.match remaining_comment
        break if ! match
        locations << (match.size == 5 \
          ? Intersection.new(*match[0 .. 4]) \
          : Block.new(*match[0 .. 6]))
        remaining_comment = remaining_comment[match.end(1) + 1, remaining_comment.length]
      end
    end
  end
  private :find_locations

end
