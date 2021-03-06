class LocationParser
  def initialize(multiword_street_names)
    names = multiword_street_names.map { |name| Street.regexp name }.join '|'
    if !names.empty?
      names += '|'
    end
    street = "(#{names}[A-Za-z0-9']+)((?:\\s+(?:#{StreetType.regexp}))?)"

    space = '[\s.,]+'

    at_a_street =
      '(?:and|&amp;|&amp;amp;|across\s+from|around|at|@|by|just\s+\w+\s+of|just\s+off|just\s+past|looking(?:\s+\w+)?\s+(?:at|to|towards?)|near)' \
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
    remove_duplicates remove_subsets find_locations comment.strip
  end

  private def find_locations(comment)
    @regexps.each_with_object([]) do |regexp, locations|
      remaining_comment = comment
      loop do
        match = regexp.match remaining_comment
        break if !match
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

  private def remove_subsets(locations)
    # This algorithm assumes that no two locations will have the same text
    locations.reject do |location|
      locations.find { |other| !other.equal?(location) && other.text.include?(location.text) }
    end
  end

  private def remove_duplicates(locations)
    locations.reject do |location|
      locations.find { |other| other.object_id < location.object_id && other.will_have_same_geocode_as(location) }
    end
  end

end
