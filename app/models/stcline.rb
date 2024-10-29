class Stcline < ActiveRecord::Base
  STREET_NAME_SYNONYMS = [
    'DIRK DIRKSEN',
    'S VAN NESS',
    "SAINT MARY'S",
    'SGT JOHN V YOUNG',
    'SO VAN NESS',
    'TIMOTHY PFLUEGER'
  ].freeze

  UNWANTED_STREET_NAMES = [
    /^FORT MASON /,
    /^FORT MILEY /,
    /^HWY /, # excludes both HWY 1 and HWY 101
    /^I-/,
    /^UNNAMED/,
    /\bOFF$/,
    /\bON$/,
    / HP$/,
    / TI$/
  ].freeze

  class << self
    def multiword_street_names
      (order(:street).select('distinct(street)').map &:street).
        select { |name| name.include? ' ' }.
        reject { |name| UNWANTED_STREET_NAMES.find { |pattern| pattern =~ name } } +
        STREET_NAME_SYNONYMS
    end

    def geocode(address)
      cline = find_cline address
      if cline
        find_point_on cline, address
      end
    end

    private

    def find_cline(address)
      number = address.number.to_i
      clines = where(street: address.street.name).
        where(
          "(lf_fadd % 2 = :number % 2 and lf_fadd <= :number and :number <= lf_toadd) or " \
            "(rt_fadd % 2 = :number % 2 and rt_fadd <= :number and :number <= rt_toadd)",
          number: number)
      street_type = address.street_type
      if street_type
        clines = clines.where st_type: street_type
      end
      if clines.length == 1 # use length to run full query for performance
        clines.first
      else
        logger.debug "Found #{clines.length} centerlines for #{address}"
        nil
      end
    end

    def find_point_on(cline, address)
      address_number = address.number.to_i
      from_address_number, to_address_number = from_and_to_addresses cline, address_number
      pos = from_address_number == to_address_number \
              ? 0.5 : (address_number - from_address_number) / (to_address_number - from_address_number)
      first = cline.SHAPE.points.first
      last = cline.SHAPE.points.last
      RGeo::Cartesian.preferred_factory.point(
        first.x + pos * (last.x - first.x), first.y + pos * (last.y - first.y)).tap do |point|
        logger.debug "Found #{address} at #{point.x}, #{point.y}"
      end
    end

    def from_and_to_addresses(cline, address_number)
      cline.lf_fadd != 0 && address_number % 2 == cline.lf_fadd % 2 \
        ? [cline.lf_fadd, cline.lf_toadd] : [cline.rt_fadd, cline.rt_toadd]
    end

  end

end
