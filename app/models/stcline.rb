class Stcline < ActiveRecord::Base

  def self.street_names
    order(:street).select('distinct(street)').map &:street
  end

  def self.geocode(address)
    number = address.number.to_i
    clines = where(:street => address.street.name.upcase) \
      .where(
        "(lf_fadd % 2 = #{number % 2} and lf_fadd <= ? and ? <= lf_toadd) or " +
          "(rt_fadd % 2 = #{number % 2} and rt_fadd <= ? and ? <= rt_toadd)",
        number, number, number, number)
    if address.street.type
      clines = clines.where :st_type => address.street.type.name
    end
    if clines.length != 1
      logger.info "Found #{clines.length} centerlines for #{address}"
      return nil
    end
    cline = clines[0]
    first = cline.SHAPE.points.first
    last = cline.SHAPE.points.last
    from_address, to_address = number % 2 == cline.lf_fadd % 2 \
      ? [cline.lf_fadd, cline.lf_toadd ] : [ cline.rt_fadd, cline.rt_toadd ]
    pos = (number - from_address) / (to_address - from_address)
    point = RGeo::Cartesian.preferred_factory.point \
      first.x + pos * (last.x - first.x), first.y + pos * (last.y - first.y)
    logger.info "Found #{address} at #{point.x}, #{point.y}"
    point
  end

end
