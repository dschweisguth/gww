class Stintersection < ActiveRecord::Base

  # TODO Dave handle alternate names for streets ('DeHaro', 'Divis')
  def self.geocode(location)
    if location.respond_to? :on
      point1 = geocode_intersection location.on, location.between1
      if ! point1
        return nil
      end
      point2 = geocode_intersection location.on, location.between2
      if point2
        midpoint = point((point1.x + point2.x) / 2, (point1.y + point2.y) / 2)
        logger.info "Found midpoint of #{location.on} " +
          "between #{location.between1} and #{location.between2} at #{midpoint.x}, #{midpoint.y}."
      else
        nil
      end
      point2 \
        ? point((point1.x + point2.x) / 2, (point1.y + point2.y) / 2) \
        : nil
    elsif location.respond_to? :number
      Stcline.geocode location
    else
      geocode_intersection location.at1, location.at2
    end
  end

  def self.geocode_intersection(street1, street2)
    sql = %q[
      select i1.* from stintersections i1, stintersections i2
      where i1.cnn = i2.cnn and i1.st_name = ? and i2.st_name = ? ]
    args = [ sql, street1.name.upcase, street2.name.upcase ]
    if street1.type
      sql << ' and i1.st_type = ?'
      args << street1.canonical_type.upcase
    end
    if street2.type
      sql << ' and i2.st_type = ?'
      args << street2.canonical_type.upcase
    end
    nodes = find_by_sql args
    if nodes.length == 1
      point = nodes[0].SHAPE
      logger.info "Found intersection of #{street1} and #{street2} at #{point.x}, #{point.y}."
      point
    else
      logger.info "Found #{nodes.length} intersections of #{street1} and #{street2}."
      nil
    end
  end
  private_class_method :geocode_intersection

  def self.point(x, y)
    RGeo::Cartesian.preferred_factory.point(x, y)
  end
  private_class_method :point

end
