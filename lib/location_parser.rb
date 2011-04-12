# TODO Dave make use of X and Y in "# #TH between X and Y"
# TODO Dave single-block streets
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

  # TODO Dave move selection of street names to Stcline
  def initialize(known_street_names)
    name = known_street_names.select { |name| name.include? ' ' } \
      .reject { |name| UNWANTED_STREET_NAMES.any? { |unwanted| name =~ unwanted } } \
      .map { |name| "(?:#{name})" }.join '|'
    if ! name.empty?
      name += '|'
    end
    name += "[A-Za-z0-9']+"
    type = "(?:\\s+(?:#{StreetType.regexp}))?"
    street = "(#{name})(#{type})"

    space = '[\s.,]+'
    
    at_a_street =
      '(?:and|&amp;|&amp;amp;|at|@|by|just\s+(?:\w+)?\s+of|just\s+past|looking(?:\s+\w+)?\s+(?:at|to|towards?)|near)' +
        "#{space}#{street}"
    between_streets =
      "(?:between|(?:betw?|btwn)\\.?)#{space}#{street}#{space}(?:and|&amp;|&amp;amp;)#{space}#{street}"
    address = '(\b\d+)(?:\s*-\s*\d+|[a-z])?\s+' + street

    @regexps = [
      /#{street}#{space}#{at_a_street}/i,
      /#{street}#{space}#{between_streets}/i,
      /#{address}/i,
      /#{address}#{space}#{at_a_street}/i,
      /#{address}#{space}#{between_streets}/i
    ]

  end

  def parse(comment)
    remove_subsets find_locations comment.strip
  end

  def find_locations(comment)
    @regexps.each_with_object([]) do |regexp, locations|
      remaining_comment = comment
      while true
        match = regexp.match remaining_comment
        break if ! match
        locations <<
          case match.size
            when 5
              Intersection.new *match
            when 7
              Block.new *match
            else # luckily, an address has 4, 6 or 8 parts
              Address.new *match
          end
        remaining_comment = remaining_comment[match.end(1) + 1, remaining_comment.length]
      end
    end
  end
  private :find_locations

  def remove_subsets(locations)
    # This algorithm assumes that no two locations will have the same text
    locations.reject { |location| locations.find \
      { |other| ! other.equal?(location) && other.text.include?(location.text) } }
  end
  private :remove_subsets

end
