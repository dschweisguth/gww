class Stintersection < ActiveRecord::Base

  def self.geocode(location)
    if location.respond_to? :on
      point1 = geocode_intersection location.on, location.between1
      if ! point1
        return nil
      end
      point2 = geocode_intersection location.on, location.between2
      if point2
        midpoint = point((point1.x + point2.x) / 2, (point1.y + point2.y) / 2)
        logger.debug "Found midpoint of #{location.on} " +
          "between #{location.between1} and #{location.between2} at #{midpoint.x}, #{midpoint.y}."
        midpoint
      else
        nil
      end
    elsif location.respond_to? :number
      Stcline.geocode location
    else
      geocode_intersection location.at1, location.at2
    end
  end

  private_class_method def self.geocode_intersection(street1, street2)
    intersections = intersections street1, street2
    if intersections.length == 1
      point = intersections[0].SHAPE
      logger.debug "Found intersection of #{street1} and #{street2} at #{point.x}, #{point.y}."
      point
    else
      logger.debug "Found #{intersections.length} intersections of #{street1} and #{street2}."
      nil
    end
  end

  private_class_method def self.point(x, y)
    RGeo::Cartesian.preferred_factory.point(x, y)
  end

  def self.street_type(street, cross_street)
    intersections = intersections street, cross_street
    street_types = (intersections.map &:st_type).uniq
    if street_types.length == 1
      street_type = street_types[0]
      logger.debug "The #{street.name} that crosses #{cross_street} is a(n) #{street_type}."
      street_type
    else
      logger.debug "Found #{street_types.length} intersections of #{street.name} and #{cross_street}."
      nil
    end
  end

  private_class_method def self.intersections(street1, street2)
    sql = %q[
      select i1.* from stintersections i1, stintersections i2
      where i1.cnn = i2.cnn and i1.st_name = ? and i2.st_name = ? ]
    args = [ sql, street1.name, street2.name ]
    if street1.type
      sql << ' and i1.st_type = ?'
      args << street1.type.name
    end
    if street2.type
      sql << ' and i2.st_type = ?'
      args << street2.type.name
    end
    find_by_sql args
  end

end
