require 'spec_helper'

describe Stintersection do

  describe '.geocode' do
    it "converts a location to a lat + long" do
      point = RGeo::Cartesian.preferred_factory.point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26th', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'Valencia', :SHAPE => point
      location = Intersection.new '26th', 'Valencia'
      Stintersection.geocode(location).should == point
    end

    after do
      Stintersection.connection.execute 'delete from stintersections' # stupid MyISAM
    end

  end

end
