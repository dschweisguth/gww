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
    name = known_street_names.select { |name| name.include? ' ' } \
      .reject { |name| UNWANTED_STREET_NAMES.any? { |unwanted| name =~ unwanted } } \
      .map { |name| "(?:#{name})" }.join '|'
    if ! name.empty?
      name += '|'
    end
    name += "[A-Za-z0-9']+"
    type = "(?:\\s+(?:#{StreetType.regexp}))?"
    street = "(#{name})(#{type})"
    unmatched_street = "(?:#{name})#{type}"

    space = '[\s.,]+'
    and_intersecting =
      '(?:and|&amp;|&amp;amp;|at|@|by|just\s+(?:\w+)?\s+of|just\s+past|looking(?:\s+\w+)?\s+(?:at|to|towards?)|near)'
    between = '(?:between|(?:betw?|btwn)\.?)'
    and_other_intersecting = '(?:and|&amp;|&amp;amp;)'

    @regexps = [
      /#{street}#{space}#{and_intersecting}#{space}#{street}/i,
      /#{street}#{space}#{between}#{space}#{street}#{space}#{and_other_intersecting}#{space}#{street}/i,
      /(\b\d+)(?:\s*-\s*\d+|[a-z])?\s+#{street}(?:#{space}(?:#{and_intersecting}|#{between}#{space}#{unmatched_street}#{space}#{and_other_intersecting})#{space}#{unmatched_street})?/i
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
            when 4
              Address.new *match
            when 5
              Intersection.new *match
            when 7
              Block.new *match
          end
        remaining_comment = remaining_comment[match.end(1) + 1, remaining_comment.length]
      end
    end
  end
  private :find_locations

  def remove_subsets(locations)
    locations.reject { |location| locations.find \
      { |other| ! other.equal?(location) && other.text.include?(location.text) } }
  end
  private :remove_subsets

end
