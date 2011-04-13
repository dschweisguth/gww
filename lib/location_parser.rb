# TODO Dave single-block streets
class LocationParser

  def initialize(multiword_street_names)
    # TODO Dave expand 'Saint' into regexp
    name = multiword_street_names \
      .map { |a_name| a_name.gsub /\bSAINT\b/, '(?:SAINT|ST\.?)' } \
      .map { |a_name| a_name.gsub /([A-ZA-z0-9']+\s+[A-ZA-z0-9'])(\s+[A-ZA-z0-9']+)/, '\1\.?\2' } \
      .map { |a_name| a_name.gsub /(\s+)JR$/, ',?\1(?:JR\.?|JUNIOR)' } \
      .map { |a_name| a_name.gsub /\s+/, '\s+' } \
      .join '|'
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

  # TODO Dave remove identical locations, e.g. those arising from synonym
  def remove_subsets(locations)
    # This algorithm assumes that no two locations will have the same text
    locations.reject { |location| locations.find \
      { |other| ! other.equal?(location) && other.text.include?(location.text) } }
  end
  private :remove_subsets

end
