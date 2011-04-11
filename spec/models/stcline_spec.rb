require 'spec_helper'

describe Stcline do
  describe '.geocode' do
    before :all do
      clear_stclines
    end

    it 'finds the lat + long of an address' do
      Stcline.create :street => 'VALENCIA', :lf_fadd => 1401, :lf_toadd => 1499, :rt_fadd => 1400, :rt_toadd => 1498,
        :SHAPE => RGeo::Cartesian.preferred_factory.line(point(1, 4), point(3, 6))
      geocode = Stcline.geocode Address.new('1450 Valencia', '1450', 'Valencia', nil)
      geocode.x.should be_within(0.001).of(2.02)
      geocode.y.should be_within(0.001).of(5.02)
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
end
