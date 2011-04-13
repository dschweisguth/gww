class Stcline < ActiveRecord::Base

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
    (order(:street).select('distinct(street)').map &:street) \
      .select { |name| name.include? ' ' } \
      .reject { |name| UNWANTED_STREET_NAMES.find { |pattern| pattern =~ name } }
  end

  def self.geocode(address)
    number = address.number.to_i
    clines = where(:street => address.street.name) \
      .where(
        "(lf_fadd % 2 = #{number % 2} and lf_fadd <= ? and ? <= lf_toadd) or " +
          "(rt_fadd % 2 = #{number % 2} and rt_fadd <= ? and ? <= rt_toadd)",
        number, number, number, number)
    if address.street.type
      clines = clines.where :st_type => address.street.type.name
    else
      cross_street = address.at || address.between1
      if cross_street
        street_type = Stintersection.street_type address.street, cross_street
        if ! street_type && address.between2
          street_type = Stintersection.street_type address.street, address.between2
        end
        if street_type
          clines = clines.where :st_type => street_type
        end
      end
    end
    if clines.length != 1
      logger.info "Found #{clines.length} centerlines for #{address}"
      return nil
    end
    cline = clines[0]
    first = cline.SHAPE.points.first
    last = cline.SHAPE.points.last
    from_address, to_address = cline.lf_fadd != 0 && number % 2 == cline.lf_fadd % 2 \
      ? [cline.lf_fadd, cline.lf_toadd ] : [ cline.rt_fadd, cline.rt_toadd ]
    pos = (number - from_address) / (to_address - from_address)
    point = RGeo::Cartesian.preferred_factory.point \
      first.x + pos * (last.x - first.x), first.y + pos * (last.y - first.y)
    logger.info "Found #{address} at #{point.x}, #{point.y}"
    point
  end

end
