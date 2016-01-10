class Stcline < ActiveRecord::Base

  STREET_NAME_SYNONYMS = [
    'DIRK DIRKSEN',
    'S VAN NESS',
    "SAINT MARY'S",
    'SGT JOHN V YOUNG',
    'SO VAN NESS',
    'TIMOTHY PFLUEGER'
  ]

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
  ]

  def self.multiword_street_names
    (order(:street).select('distinct(street)').map &:street).
      select { |name| name.include? ' ' }.
      reject { |name| UNWANTED_STREET_NAMES.find { |pattern| pattern =~ name } } +
      STREET_NAME_SYNONYMS
  end

  def self.geocode(address)
    cline = find_cline address
    if cline
      number = address.number.to_i
      from_address, to_address = cline.lf_fadd != 0 && number % 2 == cline.lf_fadd % 2 \
        ? [cline.lf_fadd, cline.lf_toadd ] : [ cline.rt_fadd, cline.rt_toadd ]
      pos = from_address == to_address ? 0.5 : (number - from_address) / (to_address - from_address)
      first = cline.SHAPE.points.first
      last = cline.SHAPE.points.last
      RGeo::Cartesian.preferred_factory.point(
        first.x + pos * (last.x - first.x), first.y + pos * (last.y - first.y)).tap do |point|
        logger.debug "Found #{address} at #{point.x}, #{point.y}"
      end
    end
  end

  private_class_method def self.find_cline(address)
    number = address.number.to_i
    clines = where(street: address.street.name).
      where(
        "(lf_fadd % 2 = :number % 2 and lf_fadd <= :number and :number <= lf_toadd) or " \
          "(rt_fadd % 2 = :number % 2 and rt_fadd <= :number and :number <= rt_toadd)",
        number: number)
    if address.street.type
      clines = clines.where st_type: address.street.type.name
    else
      cross_street = address.at || address.between1
      if cross_street
        street_type = Stintersection.street_type address.street, cross_street
        if !street_type && address.between2
          street_type = Stintersection.street_type address.street, address.between2
        end
        if street_type
          clines = clines.where st_type: street_type
        end
      end
    end
    if clines.length == 1 # use length to run full query for performance
      clines.first
    else
      logger.debug "Found #{clines.length} centerlines for #{address}"
      nil
    end
  end

end
