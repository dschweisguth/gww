class Stintersection < ActiveRecord::Base

  def self.geocode(location)
    if location.respond_to? :street
      point1 = geocode_intersection location.street, location.between1
      if ! point1
        return nil
      end
      point2 = geocode_intersection location.street, location.between2
      if point2
        midpoint = RGeo::Cartesian.preferred_factory.point(
          (point1.x + point2.x) / 2, (point1.y + point2.y) / 2)
        logger.info "Found midpoint of #{location.street} " +
          "between #{location.between1} and #{location.between2} at #{midpoint.x}, #{midpoint.y}."
      else
        nil
      end
      point2 \
        ? RGeo::Cartesian.preferred_factory.point(
          (point1.x + point2.x) / 2, (point1.y + point2.y) / 2) \
        : nil
    else
      geocode_intersection location.street1, location.street2
    end
  end

  def self.geocode_intersection(street1, street2)
    nodes = find_by_sql [
      %q[
        select i1.* from stintersections i1, stintersections i2
        where i1.cnn = i2.cnn and i1.st_name = ? and i2.st_name = ?
      ],
      street1, street2
    ]
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

end
