describe Stcline do
  before :context do
    clear_stclines
  end

  after do
    clear_stclines
  end

  describe '.street_names' do
    it "lists multiword street names" do
      Stcline.create! street: 'SAN JOSE', SHAPE: point(1, 1)
      expect(Stcline.multiword_street_names).to eq(['SAN JOSE'] + Stcline::STREET_NAME_SYNONYMS)
    end

    it "consolidates duplicates" do
      2.times { Stcline.create! street: 'SAN JOSE', SHAPE: point(1, 1) }
      expect(Stcline.multiword_street_names).to eq(['SAN JOSE'] + Stcline::STREET_NAME_SYNONYMS)
    end

    it "ignores one-word street names" do
      Stcline.create! street: 'VALENCIA', SHAPE: point(1, 1)
      expect(Stcline.multiword_street_names).to eq([] + Stcline::STREET_NAME_SYNONYMS)
    end

    it "ignores unwanted names" do
      Stcline.create! street: 'UNNAMED 001', SHAPE: point(1, 1)
      expect(Stcline.multiword_street_names).to eq([] + Stcline::STREET_NAME_SYNONYMS)
    end

  end

  describe '.geocode' do
    it "finds the lat + long of an address" do
      Stcline.create! street: 'VALENCIA',
        lf_fadd: 1401, lf_toadd: 1499, rt_fadd: 1400, rt_toadd: 1498,
        SHAPE: line(point(1, 4), point(3, 6))
      geocode = Stcline.geocode Address.new('1450 Valencia', '1450', 'Valencia', nil)
      expect(geocode.x).to be_within(0.001).of(2.02)
      expect(geocode.y).to be_within(0.001).of(5.02)
    end

    it "handles a centerline with a single address" do
      Stcline.create! street: '18TH',
        lf_fadd: 3553, lf_toadd: 3561, rt_fadd: 3560, rt_toadd: 3560,
        SHAPE: line(point(1, 4), point(3, 6))
      geocode = Stcline.geocode Address.new('3560 18th', '3560', '18th', nil)
      expect(geocode.x).to be_within(0.001).of(2)
      expect(geocode.y).to be_within(0.001).of(5)
    end

    it "ignores a too-high address range on the left side of the street" do
      Stcline.create! street: 'VALENCIA',
        lf_fadd: 1451, lf_toadd: 1499, rt_fadd: 1400, rt_toadd: 1498,
        SHAPE: line(point(1, 4), point(3, 6))
      expect(Stcline.geocode(Address.new('1449 Valencia', '1449', 'Valencia', nil))).to be_nil
    end

    it "ignores a too-low address range on the left side of the street" do
      Stcline.create! street: 'VALENCIA',
        lf_fadd: 1401, lf_toadd: 1449, rt_fadd: 1400, rt_toadd: 1498,
        SHAPE: line(point(1, 4), point(3, 6))
      expect(Stcline.geocode(Address.new('1451 Valencia', '1451', 'Valencia', nil))).to be_nil
    end

    it "ignores a too-high address range on the right side of the street" do
      Stcline.create! street: 'VALENCIA',
        lf_fadd: 1401, lf_toadd: 1499, rt_fadd: 1450, rt_toadd: 1498,
        SHAPE: line(point(1, 4), point(3, 6))
      expect(Stcline.geocode(Address.new('1448 Valencia', '1448', 'Valencia', nil))).to be_nil
    end

    it "ignores a too-low address range on the right side of the street" do
      Stcline.create! street: 'VALENCIA',
        lf_fadd: 1401, lf_toadd: 1499, rt_fadd: 1400, rt_toadd: 1450,
        SHAPE: line(point(1, 4), point(3, 6))
      expect(Stcline.geocode(Address.new('1452 Valencia', '1452', 'Valencia', nil))).to be_nil
    end

    it "handles missing odd address numbers when looking up an even address number" do
      Stcline.create! street: 'VALENCIA',
        lf_fadd: 0, lf_toadd: 0, rt_fadd: 1400, rt_toadd: 1498,
        SHAPE: line(point(1, 4), point(3, 6))
      geocode = Stcline.geocode Address.new('1450 Valencia', '1450', 'Valencia', nil)
      expect(geocode.x).to be_within(0.001).of(2.02)
      expect(geocode.y).to be_within(0.001).of(5.02)
    end

    it "declines to geocode an address which matches two centerlines" do
      Stcline.create! street: 'CALIFORNIA', st_type: 'ST',
        lf_fadd: 501, lf_toadd: 599, rt_fadd: 500, rt_toadd: 598,
        SHAPE: line(point(1, 4), point(3, 6))
      Stcline.create! street: 'CALIFORNIA', st_type: 'AVE',
        lf_fadd: 501, lf_toadd: 599, rt_fadd: 500, rt_toadd: 598,
        SHAPE: line(point(11, 14), point(13, 16))
      expect(Stcline.geocode(Address.new('555 California', '555', 'California', nil))).to be_nil
    end

    it "considers street type" do
      Stcline.create! street: 'CALIFORNIA', st_type: 'ST',
        lf_fadd: 501, lf_toadd: 599, rt_fadd: 500, rt_toadd: 598,
        SHAPE: line(point(1, 4), point(3, 6))
      Stcline.create! street: 'CALIFORNIA', st_type: 'AVE',
        lf_fadd: 501, lf_toadd: 599, rt_fadd: 500, rt_toadd: 598,
        SHAPE: line(point(11, 14), point(13, 16))
      geocode = Stcline.geocode Address.new('555 California Street', '555', 'California', 'Street')
      expect(geocode.x).to be_within(0.001).of(2.102)
      expect(geocode.y).to be_within(0.001).of(5.102)
    end

    it "uses the cross street to disambiguate the street, given an address at an intersection" do
      Stcline.create! street: '19TH', st_type: 'ST',
        lf_fadd: 3601, lf_toadd: 3661, rt_fadd: 3600, rt_toadd: 3656,
        SHAPE: line(point(1, 4), point(3, 6))
      Stcline.create! street: '19TH', st_type: 'AVE',
        lf_fadd: 3600, lf_toadd: 3698, rt_fadd: 0, rt_toadd: 0,
        SHAPE: line(point(11, 14), point(13, 16))
      address = Address.new('3620 19th near Guerrero', '3620', '19th', nil, 'Guerrero', nil)
      allow(Stintersection).to receive(:street_type).with(address.street, address.at).and_return('ST')
      geocode = Stcline.geocode address
      expect(geocode.x).to be_within(0.001).of(1.714)
      expect(geocode.y).to be_within(0.001).of(4.714)
    end

    it "uses the first adjacent street to disambiguate the street, given an address on a block" do
      Stcline.create! street: '19TH', st_type: 'ST',
        lf_fadd: 3601, lf_toadd: 3661, rt_fadd: 3600, rt_toadd: 3656,
        SHAPE: line(point(1, 4), point(3, 6))
      Stcline.create! street: '19TH', st_type: 'AVE',
        lf_fadd: 3600, lf_toadd: 3698, rt_fadd: 0, rt_toadd: 0,
        SHAPE: line(point(11, 14), point(13, 16))
      address = Address.new(
        '3620 19th between Guerrero and Dolores', '3620', '19th', nil, 'Guerrero', nil, 'Dolores', nil)
      allow(Stintersection).to receive(:street_type).with(address.street, address.between1).and_return('ST')
      geocode = Stcline.geocode address
      expect(geocode.x).to be_within(0.001).of(1.714)
      expect(geocode.y).to be_within(0.001).of(4.714)
    end

    it "uses the second adjacent street to disambiguate the street if necessary, given an address on a block" do
      Stcline.create! street: '19TH', st_type: 'ST',
        lf_fadd: 3601, lf_toadd: 3661, rt_fadd: 3600, rt_toadd: 3656,
        SHAPE: line(point(1, 4), point(3, 6))
      Stcline.create! street: '19TH', st_type: 'AVE',
        lf_fadd: 3600, lf_toadd: 3698, rt_fadd: 0, rt_toadd: 0,
        SHAPE: line(point(11, 14), point(13, 16))
      address = Address.new(
        '3620 19th between Guerrero and Dolores', '3620', '19th', nil, 'Guerrero', nil, 'Dolores', nil)
      allow(Stintersection).to receive(:street_type).with(address.street, address.between1).and_return(nil)
      allow(Stintersection).to receive(:street_type).with(address.street, address.between2).and_return('ST')
      geocode = Stcline.geocode address
      expect(geocode.x).to be_within(0.001).of(1.714)
      expect(geocode.y).to be_within(0.001).of(4.714)
    end

  end

  def point(x, y)
    RGeo::Cartesian.preferred_factory.point(x, y)
  end

  def line(first, last)
    RGeo::Cartesian.preferred_factory.line(first, last)
  end

  def clear_stclines
    Stcline.connection.execute 'delete from stclines' # stupid MyISAM
  end

end
