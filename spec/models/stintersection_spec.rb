describe Stintersection do
  before :context do
    clear_stintersections
  end

  after do
    clear_stintersections
  end

  describe '.geocode' do
    it "converts an intersection to a lat + long" do
      make_intersection 1, '26TH', 'ST', point(1, 2)
      make_intersection 1, 'VALENCIA', 'ST', point(1, 2)
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      expect(Stintersection.geocode(location)).to eq(point(1, 2))
    end

    it "converts a block to a lat + long" do
      make_intersection 1, '25TH', 'ST', point(1, 3)
      make_intersection 1, 'VALENCIA', 'ST', point(1, 3)
      make_intersection 2, '26TH', 'ST', point(2, 4)
      make_intersection 2, 'VALENCIA', 'ST', point(2, 4)
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      expect(Stintersection.geocode(location)).to eq(point(1.5, 3.5))
    end

    it "returns nil if the block's first intersection isn't found" do
      make_intersection 2, '26TH', 'ST', point(1, 3)
      make_intersection 2, 'VALENCIA', 'ST', point(1, 3)
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      expect(Stintersection.geocode(location)).to be_nil
    end

    it "returns nil if the block's second intersection isn't found" do
      make_intersection 1, '25TH', 'ST', point(2, 4)
      make_intersection 1, 'VALENCIA', 'ST', point(2, 4)
      location = Block.new 'Valencia between 25th and 26th', 'Valencia', nil, '25th', nil, '26th', nil
      expect(Stintersection.geocode(location)).to be_nil
    end

    it "converts an address to a lat + long" do
      location = Address.new '555 California', '555', 'California', nil
      point = point(1, 2)
      allow(Stcline).to receive(:geocode).with(location).and_return(point)
      expect(Stintersection.geocode(location)).to eq(point)
    end

    it "returns nil if an intersection is ambiguous" do
      make_intersection 1, '26TH', 'ST', point(1, 2)
      make_intersection 1, 'VALENCIA', 'ST', point(1, 2)
      make_intersection 2, '26TH', 'AVE', point(3, 4)
      make_intersection 2, 'VALENCIA', 'ST', point(3, 4)
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', 'St'
      expect(Stintersection.geocode(location)).to be_nil
    end

    it "uses the street's type when present" do
      make_intersection 1, '26TH', 'ST', point(1, 2)
      make_intersection 1, 'VALENCIA', 'ST', point(1, 2)
      make_intersection 2, '26TH', 'AVE', point(3, 4)
      make_intersection 2, 'VALENCIA', 'ST', point(3, 4)
      location = Intersection.new '26th and Valencia', '26th', 'St', 'Valencia', nil
      expect(Stintersection.geocode(location)).to eq(point(1, 2))
    end

    it "uses the cross street's type when present" do
      make_intersection 1, '26TH', 'ST', point(1, 2)
      make_intersection 1, 'VALENCIA', 'ST', point(1, 2)
      make_intersection 2, '26TH', 'ST', point(3, 4)
      make_intersection 2, 'VALENCIA', 'AVE', point(3, 4)
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', 'St'
      expect(Stintersection.geocode(location)).to eq(point(1, 2))
    end

  end

  describe '.street_type' do
    it "finds the type of an untyped street with a cross street" do
      make_intersection 1, '20TH', 'ST', point(1, 2)
      make_intersection 1, 'GUERRERO', 'ST', point(1, 2)
      expect(Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero'))).to eq('ST')
    end

    it "returns nil if the intersection is ambiguous" do
      make_intersection 1, '20TH', 'ST', point(1, 2)
      make_intersection 1, 'GUERRERO', 'ST', point(1, 2)
      make_intersection 2, '20TH', 'AVE', point(3, 4)
      make_intersection 2, 'GUERRERO', 'AVE', point(3, 4)
      expect(Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero'))).to be_nil
    end

    it "succeeds if the intersection is ambiguous but the street type is not" do
      make_intersection 1, '20TH', 'ST', point(1, 2)
      make_intersection 1, 'GUERRERO', 'ST', point(1, 2)
      make_intersection 2, '20TH', 'ST', point(3, 4)
      make_intersection 2, 'GUERRERO', 'AVE', point(3, 4)
      expect(Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero'))).to eq('ST')
    end

    it "uses the cross street's type when present" do
      make_intersection 1, '20TH', 'ST', point(1, 2)
      make_intersection 1, 'GUERRERO', 'ST', point(1, 2)
      make_intersection 2, '20TH', 'AVE', point(3, 4)
      make_intersection 2, 'GUERRERO', 'AVE', point(3, 4)
      expect(Stintersection.street_type(Street.new('20TH'), Street.new('Guerrero', 'ST'))).to eq('ST')
    end

  end

  def point(x, y)
    RGeo::Cartesian.preferred_factory.point(x, y)
  end

  def make_intersection(cnn, street_name, street_type, point)
    Stintersection.create! cnn: cnn, st_name: street_name, st_type: street_type, SHAPE: point
  end

  def clear_stintersections
    Stintersection.connection.execute 'delete from stintersections' # stupid MyISAM
  end

end
