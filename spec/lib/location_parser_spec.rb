describe LocationParser, type: :lib do
  describe '#parse' do
    let(:parser) { LocationParser.new([]) }

    it "finds no locations in the empty string" do
      expect(parser.parse('')).to eq([])
    end

    it "finds an intersection" do
      text = '26th and Valencia'
      expect(parser.parse(text)).to eq([Intersection.new(text, '26th', nil, 'Valencia', nil)])
    end

    it "accepts periods and commas around an intersection's connecting word(s)" do
      text = '26th ., and ., Valencia'
      expect(parser.parse(text)).to eq([Intersection.new(text, '26th', nil, 'Valencia', nil)])
    end

    %w(between bet bet. betw betw. btwn btwn.).each do |between|
      it "finds a block delimited with '#{between}'" do
        text = "Valencia #{between} 25th and 26th"
        expect(parser.parse(text)).to eq([Block.new(text, 'Valencia', nil, '25th', nil, '26th', nil)])
      end
    end

    it "accepts periods and commas around a block's connecting words" do
      text = 'Valencia ., between ., 25th ., and ., 26th'
      expect(parser.parse(text)).to eq([Block.new(text, 'Valencia', nil, '25th', nil, '26th', nil)])
    end

    it "finds a plain address" do
      text = '555 California'
      expect(parser.parse(text)).to eq([Address.new(text, '555', 'California', nil)])
    end

    it "finds an address at an intersection" do
      text = '555 California near Kearny'
      expect(parser.parse(text)).to eq([Address.new(text, '555', 'California', nil, 'Kearny', nil)])
    end

    it "finds an address with adjacent streets" do
      text = '555 California between Montgomery and Kearny'
      expect(parser.parse(text)).to eq([Address.new(text, '555', 'California', nil, 'Montgomery', '', 'Kearny', '')])
    end

    it "ignores a potential address number not on a word boundary" do
      expect(parser.parse('A1 Steak Sauce')).to eq([])
    end

    it "finds an address with multiple address numbers" do
      text = '393-399 Valencia'
      expect(parser.parse(text)).to eq([Address.new(text, '393', 'Valencia', nil)])
    end

    it "finds an address with a letter" do
      text = '393A Valencia'
      expect(parser.parse(text)).to eq([Address.new(text, '393', 'Valencia', nil)])
    end

    it "finds a location with a street with a multiword name" do
      text = '26th and San Jose'
      expect(LocationParser.new(['SAN JOSE']).parse(text)).to eq([Intersection.new(text, '26th', nil, 'San Jose', nil)])
    end

    it "treats an unknown multi-word name as a series of single words" do
      expect(parser.parse('26th and San Jose')).to eq([Intersection.new('26th and San', '26th', nil, 'San', nil)])
    end

    it "finds a location with a street type" do
      text = '26th St and Valencia'
      expect(parser.parse(text)).to eq([Intersection.new(text, '26th', 'St', 'Valencia', nil)])
    end

    it "finds multiple locations" do
      expect(parser.parse('25th and Valencia 26th and Valencia')).to eq(
        [Intersection.new('25th and Valencia', '25th', nil, 'Valencia', nil),
          Intersection.new('26th and Valencia', '26th', nil, 'Valencia', nil)]
      )
    end

    it "finds overlapping locations" do
      expect(parser.parse('lions and tigers and bears')).to eq(
        [Intersection.new('lions and tigers', 'lions', nil, 'tigers', nil),
          Intersection.new('tigers and bears', 'tigers', nil, 'bears', nil)]
      )
    end

    context "parser knows that Dirk Dirksen is a multiword street name" do
      let(:parser) { LocationParser.new(['DIRK DIRKSEN']) }

      it "eliminates locations which will have the same geocode" do
        expect(parser.parse('Rowland at Broadway Dirk Dirksen at Broadway').length).to eq(1)
      end

      it "eliminates blocks which will have the same geocode" do
        expect(parser.parse(
          'Broadway between Rowland and Kearny Broadway between Dirk Dirksen and Kearny').length).to eq(1)
      end

      it "eliminates addresses which will have the same geocode" do
        expect(parser.parse('100 Rowland 100 Dirk Dirksen').length).to eq(1)
      end

    end

  end
end
