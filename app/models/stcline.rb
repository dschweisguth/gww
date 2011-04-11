class Stcline < ActiveRecord::Base

  def self.street_names
    (order(:street).map &:street).uniq
  end

  def self.geocode(address)
    number = address.number.to_i
    clines = where(:street => address.street.name.upcase) \
      .where('(lf_fadd <= ? and ? <= lf_toadd) or (rt_fadd <= ? or ? <= rt_toadd)',
        number, number, number, number)
    if clines.length != 1
      raise "Found #{clines.length} centerlines for #{address}?!?"
    end
    cline = clines[0]
    line = cline.SHAPE
    if line.num_points != 2
      raise "Centerline has #{line.num_points} points?!?"
    end
    from_address, to_address =
      (number.even? && cline.lf_fadd.to_i.even?) || (number.odd? && cline.lf_fadd.to_i.odd?) \
        ? [ cline.lf_fadd, cline.lf_toadd ] : [ cline.rt_fadd, cline.rt_toadd ]
    pos = (number - from_address) / (to_address - from_address)
    RGeo::Cartesian.preferred_factory.point \
      line.points[0].x + pos * (line.points[1].x - line.points[0].x),
      line.points[0].y + pos * (line.points[1].y - line.points[0].y)
  end

end
