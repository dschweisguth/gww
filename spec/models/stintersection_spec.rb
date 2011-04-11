require 'spec_helper'

describe Stintersection do

  describe '.geocode' do
    it "converts an intersection to a lat + long" do
      point = RGeo::Cartesian.preferred_factory.point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26th', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'Valencia', :SHAPE => point
      location = Intersection.new '26th', 'Valencia'
      Stintersection.geocode(location).should == point
    end

    it "converts a block to a lat + long" do
      point1 = RGeo::Cartesian.preferred_factory.point(38, -121)
      Stintersection.create! :cnn => 1, :st_name => '25th', :SHAPE => point1
      Stintersection.create! :cnn => 1, :st_name => 'Valencia', :SHAPE => point1
      point2 = RGeo::Cartesian.preferred_factory.point(37, -122)
      Stintersection.create! :cnn => 2, :st_name => '26th', :SHAPE => point2
      Stintersection.create! :cnn => 2, :st_name => 'Valencia', :SHAPE => point2
      location = Block.new 'Valencia', '25th', '26th'
      Stintersection.geocode(location).should == RGeo::Cartesian.preferred_factory.point(37.5, -121.5)
    end

    after do
      Stintersection.connection.execute 'delete from stintersections' # stupid MyISAM
    end

  end

end
