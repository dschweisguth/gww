require 'spec_helper'

describe Stcline do
  before :all do
    clear_stclines
  end

  describe '.street_names' do
    it "lists street names" do
      Stcline.create! :street => 'VALENCIA', :SHAPE => point(1, 1)
      Stcline.street_names.should == [ 'VALENCIA' ]
    end

    it "consolidates duplicates" do
      Stcline.create! :street => 'VALENCIA', :SHAPE => point(1, 1)
      Stcline.create! :street => 'VALENCIA', :SHAPE => point(1, 1)
      Stcline.street_names.should == [ 'VALENCIA' ]
    end

  end

  describe '.geocode' do

    it "finds the lat + long of an address" do
      Stcline.create! :street => 'VALENCIA', :lf_fadd => 1401, :lf_toadd => 1499, :rt_fadd => 1400, :rt_toadd => 1498,
        :SHAPE => RGeo::Cartesian.preferred_factory.line(point(1, 4), point(3, 6))
      geocode = Stcline.geocode Address.new('1450 Valencia', '1450', 'Valencia', nil)
      geocode.x.should be_within(0.001).of(2.02)
      geocode.y.should be_within(0.001).of(5.02)
    end

    it "ignores a too-high address range on the left side of the street" do
      Stcline.create! :street => 'VALENCIA', :lf_fadd => 1451, :lf_toadd => 1499, :rt_fadd => 1400, :rt_toadd => 1498,
        :SHAPE => RGeo::Cartesian.preferred_factory.line(point(1, 4), point(3, 6))
      Stcline.geocode(Address.new('1449 Valencia', '1449', 'Valencia', nil)).should == nil
    end

    it "ignores a too-low address range on the left side of the street" do
      Stcline.create! :street => 'VALENCIA', :lf_fadd => 1401, :lf_toadd => 1449, :rt_fadd => 1400, :rt_toadd => 1498,
        :SHAPE => RGeo::Cartesian.preferred_factory.line(point(1, 4), point(3, 6))
      Stcline.geocode(Address.new('1451 Valencia', '1451', 'Valencia', nil)).should == nil
    end

    it "ignores a too-high address range on the right side of the street" do
      Stcline.create! :street => 'VALENCIA', :lf_fadd => 1401, :lf_toadd => 1499, :rt_fadd => 1450, :rt_toadd => 1498,
        :SHAPE => RGeo::Cartesian.preferred_factory.line(point(1, 4), point(3, 6))
      Stcline.geocode(Address.new('1448 Valencia', '1448', 'Valencia', nil)).should == nil
    end

    it "ignores a too-low address range on the right side of the street" do
      Stcline.create! :street => 'VALENCIA', :lf_fadd => 1401, :lf_toadd => 1499, :rt_fadd => 1400, :rt_toadd => 1450,
        :SHAPE => RGeo::Cartesian.preferred_factory.line(point(1, 4), point(3, 6))
      Stcline.geocode(Address.new('1452 Valencia', '1452', 'Valencia', nil)).should == nil
    end

  end

  def point(x, y)
    RGeo::Cartesian.preferred_factory.point(x, y)
  end

  after do
    clear_stclines
  end

  def clear_stclines
    Stcline.connection.execute 'delete from stclines' # stupid MyISAM
  end

end
