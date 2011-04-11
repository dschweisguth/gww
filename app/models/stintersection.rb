class Stintersection < ActiveRecord::Base

  # TODO Dave handle alternate names for streets
  # TODO Dave handle 'street' etc. and abbreviations
  def self.geocode(location)
    if location.respond_to? :on
      point1 = geocode_intersection location.on.name, location.between1.name
      if ! point1
        return nil
      end
      point2 = geocode_intersection location.on.name, location.between2.name
      if point2
        midpoint = RGeo::Cartesian.preferred_factory.point(
          (point1.x + point2.x) / 2, (point1.y + point2.y) / 2)
        logger.info "Found midpoint of #{location.on} " +
          "between #{location.between1} and #{location.between2} at #{midpoint.x}, #{midpoint.y}."
      else
        nil
      end
      point2 \
        ? RGeo::Cartesian.preferred_factory.point(
          (point1.x + point2.x) / 2, (point1.y + point2.y) / 2) \
        : nil
    else
      geocode_intersection location.street1.name, location.street2.name
    end
  end

  def self.geocode_intersection(name1, name2)
    nodes = find_by_sql [
      %q[
        select i1.* from stintersections i1, stintersections i2
        where i1.cnn = i2.cnn and i1.st_name = ? and i2.st_name = ?
      ],
      name1, name2
    ]
    if nodes.length == 1
      point = nodes[0].SHAPE
      logger.info "Found intersection of #{name1} and #{name2} at #{point.x}, #{point.y}."
      point
    else
      logger.info "Found #{nodes.length} intersections of #{name1} and #{name2}."
      nil
    end
  end
  private_class_method :geocode_intersection

end
