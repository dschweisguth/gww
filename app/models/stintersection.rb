class Stintersection < ActiveRecord::Base

  def self.geocode(location)
    nodes = find_by_sql [
      %q[
        select i1.* from stintersections i1, stintersections i2
        where i1.cnn = i2.cnn and i1.st_name = ? and i2.st_name = ?
      ],
      location.street1, location.street2
    ]
    if nodes.length == 1
      point = nodes[0].SHAPE
      logger.info "Found geocode #{point.x}, #{point.y}"
      return point
    else
      logger.info "Found #{nodes.length} intersections of #{location.street1} and #{location.street2}."
      return nil
    end
  end

end
