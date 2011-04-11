require 'spec_helper'

describe Stintersection do

  describe '.geocode' do
    before :all do
      clear_stintersections
    end

    it "converts an intersection to a lat + long" do
      point = RGeo::Cartesian.preferred_factory.point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      Stintersection.geocode(location).should == point
    end

    it "converts a block to a lat + long" do
      point1 = RGeo::Cartesian.preferred_factory.point(38, -121)
      Stintersection.create! :cnn => 1, :st_name => '25TH', :st_type => 'ST', :SHAPE => point1
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point1
      point2 = RGeo::Cartesian.preferred_factory.point(37, -122)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'ST', :SHAPE => point2
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point2
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      Stintersection.geocode(location).should == RGeo::Cartesian.preferred_factory.point(37.5, -121.5)
    end

    after do
      clear_stintersections
    end

    def clear_stintersections
      Stintersection.connection.execute 'delete from stintersections' # stupid MyISAM
    end

  end

end
