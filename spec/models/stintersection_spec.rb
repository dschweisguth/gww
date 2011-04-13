require 'spec_helper'

describe Stintersection do

  before :all do
    clear_stintersections
  end

  describe '.geocode' do

    it "converts an intersection to a lat + long" do
      point = point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      Stintersection.geocode(location).should == point
    end

    it "converts a block to a lat + long" do
      point1 = point(38, -121)
      Stintersection.create! :cnn => 1, :st_name => '25TH', :st_type => 'ST', :SHAPE => point1
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point1
      point2 = point(37, -122)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'ST', :SHAPE => point2
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point2
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      Stintersection.geocode(location).should == point(37.5, -121.5)
    end

    it "converts an address to a lat + long" do
      location = Address.new '555 California', '555', 'California', nil
      point = point(1, 2)
      stub(Stcline).geocode(location) { point }
      Stintersection.geocode(location).should == point
    end

    it "uses street type when present" do
      point = point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point
      wrong_point = point(38, -121)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'AVE', :SHAPE => wrong_point
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => wrong_point
      location = Intersection.new '26th and Valencia', '26th', 'St', 'Valencia', nil
      Stintersection.geocode(location).should == point
    end

    it "ignores any trailing period in street type" do
      point = point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point
      location = Intersection.new '26th and Valencia', '26th', 'St.', 'Valencia', nil
      Stintersection.geocode(location).should == point
    end

    it "canonicalizes street type" do
      point = point(37, -122)
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point
      location = Intersection.new '26th and Valencia', '26th', 'Street', 'Valencia', nil
      Stintersection.geocode(location).should == point
    end

  end

  describe '.street_type' do
    it "finds the type of an untyped street with a cross street" do
      Stintersection.create! :cnn => 1, :st_name => '20TH', :st_type => 'ST', :SHAPE => point(1, 4)
      Stintersection.create! :cnn => 1, :st_name => 'GUERRERO', :st_type => 'ST', :SHAPE => point(1, 4)
      Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero')).should == 'ST'
    end

    it "uses the cross street's type if present" do
      Stintersection.create! :cnn => 1, :st_name => '20TH', :st_type => 'ST', :SHAPE => point(1, 4)
      Stintersection.create! :cnn => 1, :st_name => 'GUERRERO', :st_type => 'ST', :SHAPE => point(1, 4)
      Stintersection.create! :cnn => 2, :st_name => '20TH', :st_type => 'AVE', :SHAPE => point(3, 6)
      Stintersection.create! :cnn => 2, :st_name => 'GUERRERO', :st_type => 'AVE', :SHAPE => point(3, 6)
      Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero', 'ST')).should == 'ST'
    end

    it "returns nil if there is more than one possible street type" do
      Stintersection.create! :cnn => 1, :st_name => '20TH', :st_type => 'ST', :SHAPE => point(1, 4)
      Stintersection.create! :cnn => 1, :st_name => 'GUERRERO', :st_type => 'ST', :SHAPE => point(1, 4)
      Stintersection.create! :cnn => 2, :st_name => '20TH', :st_type => 'AVE', :SHAPE => point(3, 6)
      Stintersection.create! :cnn => 2, :st_name => 'GUERRERO', :st_type => 'AVE', :SHAPE => point(3, 6)
      Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero')).should == nil
    end

  end

  def point(x, y)
    RGeo::Cartesian.preferred_factory.point(x, y)
  end

  after do
    clear_stintersections
  end

  def clear_stintersections
    Stintersection.connection.execute 'delete from stintersections' # stupid MyISAM
  end

end
