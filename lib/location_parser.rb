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

  STREET_TYPES = %w{
    ALY
    ALLEY
    AVE
    AVENUE
    BLVD
    BOULEVARD
    CIR
    CIRCLE
    CT
    COURT
    DR
    DRIVE
    EXPY
    EXPRESSWAY
    HL
    HILL
    HWY
    HIGHWAY
    LN
    LANE
    LOOP
    PARK
    PATH
    PL
    PLACE
    PLZ
    PLAZA
    RAMP
    RD
    ROAD
    ROW
    ST
    STREET
    STPS
    STEPS
    STWY
    STAIRS
    STAIRWAY
    TER
    TERRACE
    TUNL
    TUNNEL
    WALK
    WAY
  }

  def initialize(known_street_names)
    # TODO Dave move parens to name, merge name and type
    name = known_street_names.select { |name| name.include? ' ' } \
      .reject { |name| UNWANTED_STREET_NAMES.any? { |unwanted| name =~ unwanted } } \
      .map { |name| "(?:#{name})" }.join '|'
    if ! name.empty?
      name += '|'
    end
    name += "[A-Za-z0-9']+"

    type = "((?:\\s+(?:#{STREET_TYPES.join('|')})\\.?)?)"

    @regexps = [
      /(#{name})#{type}\s+(?:between|bet\.)\s+(#{name})#{type}\s+(?:and|&amp;)\s+(#{name})#{type}/i,
      /(#{name})#{type}\s+(?:and|&amp;|at|@|by|near)\s+(#{name})#{type}/i
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
