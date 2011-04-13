require 'spec_helper'

describe Stintersection do

  before :all do
    clear_stintersections
  end

  describe '.geocode' do

    it "converts an intersection to a lat + long" do
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(1, 2)
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      Stintersection.geocode(location).should == point(1, 2)
    end

    it "converts a block to a lat + long" do
      Stintersection.create! :cnn => 1, :st_name => '25TH', :st_type => 'ST', :SHAPE => point(1, 3)
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(1, 3)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(2, 4)
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(2, 4)
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      Stintersection.geocode(location).should == point(1.5, 3.5)
    end

    it "returns nil if the block's first intersection isn't found" do
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(1, 3)
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(1, 3)
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      Stintersection.geocode(location).should == nil
    end

    it "returns nil if the block's second intersection isn't found" do
      Stintersection.create! :cnn => 1, :st_name => '25TH', :st_type => 'ST', :SHAPE => point(2, 4)
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(2, 4)
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      Stintersection.geocode(location).should == nil
    end

    it "converts an address to a lat + long" do
      location = Address.new '555 California', '555', 'California', nil
      point = point(1, 2)
      stub(Stcline).geocode(location) { point }
      Stintersection.geocode(location).should == point
    end

    it "returns nil if an intersection is ambiguous" do
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'AVE', :SHAPE => point(3, 4)
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(3, 4)
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', 'St'
      Stintersection.geocode(location).should == nil
    end

    it "uses the street's type when present" do
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'AVE', :SHAPE => point(3, 4)
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(3, 4)
      location = Intersection.new '26th and Valencia', '26th', 'St', 'Valencia', nil
      Stintersection.geocode(location).should == point(1, 2)
    end

    it "uses the cross street's type when present" do
      Stintersection.create! :cnn => 1, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'VALENCIA', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 2, :st_name => '26TH', :st_type => 'ST', :SHAPE => point(3, 4)
      Stintersection.create! :cnn => 2, :st_name => 'VALENCIA', :st_type => 'AVE', :SHAPE => point(3, 4)
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', 'St'
      Stintersection.geocode(location).should == point(1, 2)
    end

  end

  describe '.street_type' do
    it "finds the type of an untyped street with a cross street" do
      Stintersection.create! :cnn => 1, :st_name => '20TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'GUERRERO', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero')).should == 'ST'
    end

    it "returns nil if the intersection is ambiguous" do
      Stintersection.create! :cnn => 1, :st_name => '20TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'GUERRERO', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 2, :st_name => '20TH', :st_type => 'AVE', :SHAPE => point(3, 4)
      Stintersection.create! :cnn => 2, :st_name => 'GUERRERO', :st_type => 'AVE', :SHAPE => point(3, 4)
      Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero')).should == nil
    end

    it "uses the cross street's type when present" do
      Stintersection.create! :cnn => 1, :st_name => '20TH', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 1, :st_name => 'GUERRERO', :st_type => 'ST', :SHAPE => point(1, 2)
      Stintersection.create! :cnn => 2, :st_name => '20TH', :st_type => 'AVE', :SHAPE => point(3, 4)
      Stintersection.create! :cnn => 2, :st_name => 'GUERRERO', :st_type => 'AVE', :SHAPE => point(3, 4)
      Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero', 'ST')).should == 'ST'
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
