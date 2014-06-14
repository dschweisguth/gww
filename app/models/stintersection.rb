class Stintersection < ActiveRecord::Base

  def self.geocode(location)
    if location.respond_to? :on
      point1 = geocode_intersection location.on, location.between1
      if ! point1
        return nil # return immediately for performance
      end
      point2 = geocode_intersection location.on, location.between2
      if point2
        point((point1.x + point2.x) / 2, (point1.y + point2.y) / 2).tap do |midpoint|
          logger.debug "Found midpoint of #{location.on} " +
            "between #{location.between1} and #{location.between2} at #{midpoint.x}, #{midpoint.y}."
        end
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
      intersections[0].SHAPE.tap do |point|
        logger.debug "Found intersection of #{street1} and #{street2} at #{point.x}, #{point.y}."
      end
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
      street_types[0].tap do |street_type|
        logger.debug "The #{street.name} that crosses #{cross_street} is a(n) #{street_type}."
      end
    else
      logger.debug "Found #{street_types.length} intersections of #{street.name} and #{cross_street}."
      nil
    end
  end

  private_class_method def self.intersections(street1, street2)
    query = joins("join stintersections i2 on stintersections.cnn = i2.cnn")
      .where(st_name: street1.name)
      .where("i2.st_name = ?", street2.name)
     if street1.type
       query = query.where st_type: street1.type.name
     end
     if street2.type
       query = query.where "i2.st_type = ?", street2.type.name
     end
     query
  end

end
