require 'spec_helper'

describe LocationParser do

  it "finds no locations in the empty string" do
    LocationParser.new([]).parse('').should == []
  end

  it "finds an intersection" do
    text = '26th and Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', nil, 'Valencia', nil ]
  end

  it "accepts periods and commas around an intersection's connecting word(s)" do
    text = '26th ., and ., Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', nil, 'Valencia', nil ]
  end

  %w{ between bet bet. betw betw. btwn btwn. }.each do |between|
    it "finds a block delimited with '#{between}'" do
      text = "Valencia #{between} 25th and 26th"
      LocationParser.new([]).parse(text).should == [ Block.new text, 'Valencia', nil, '25th', nil, '26th', nil ]
    end
  end

  it "accepts periods and commas around a block's connecting words" do
    text = 'Valencia ., between ., 25th ., and ., 26th'
    LocationParser.new([]).parse(text).should == [ Block.new text, 'Valencia', nil, '25th', nil, '26th', nil ]
  end

  it "finds a plain address" do
    text = '555 California'
    LocationParser.new([]).parse(text).should == [ Address.new text, '555', 'California', nil ]
  end

  it "finds an address at an intersection" do
    text = '555 California near Kearny'
    LocationParser.new([]).parse(text).should == [ Address.new text, '555', 'California', nil, 'Kearny', nil ]
  end

  it "finds an address with adjacent streets" do
    text = '555 California between Montgomery and Kearny'
    LocationParser.new([]).parse(text).should == [ Address.new text, '555', 'California', nil, 'Montgomery', '', 'Kearny', '']
  end

  it "ignores a potential address number not on a word boundary" do
    LocationParser.new([]).parse('A1 Steak Sauce').should == []
  end

  it "finds an address with multiple address numbers" do
    text = '393-399 Valencia'
    LocationParser.new([]).parse(text).should == [ Address.new text, '393', 'Valencia', nil ]
  end

  it "finds an address with a letter" do
    text = '393A Valencia'
    LocationParser.new([]).parse(text).should == [ Address.new text, '393', 'Valencia', nil ]
  end

  it "finds a location with a street with a multiword name" do
    text = '26th and San Jose'
    LocationParser.new([ 'SAN JOSE' ]).parse(text).should == [ Intersection.new text, '26th', nil, 'San Jose', nil ]
  end

  it "accepts any whitespace within multiword names" do
    text = "Charles \n J \n Brenham and Market"
    LocationParser.new([ 'CHARLES J BRENHAM' ]).parse(text).should ==
      [ Intersection.new text, "Charles \n J \n Brenham", nil, 'Market', nil ]
  end

  %w{ Saint St St. }.each do |title|
    it "accepts #{title}" do
      LocationParser.new([ 'SAINT FRANCIS', ]).parse("#{title} Francis and Sloat").should ==
        [ Intersection.new "#{title} Francis and Sloat", "#{title} Francis", nil, 'Sloat', nil ]
    end
  end

  %w{ San S S. }.each do |title|
    it "accepts #{title}" do
      text = "#{title} Jacinto and Monterey"
      LocationParser.new([ 'SAN JACINTO' ]).parse(text).should ==
        [ Intersection.new text, "#{title} Jacinto", nil, 'Monterey', nil ]
    end
  end

  %w{ Santa Sta Sta. }.each do |title|
    it "accepts #{title}" do
      text = "#{title} Clara and Portola"
      LocationParser.new([ 'SANTA CLARA' ]).parse(text).should ==
        [ Intersection.new text, "#{title} Clara", nil, 'Portola', nil ]
    end
  end

  it "accepts a period after an apparent middle initial" do
    text = 'Charles J. Brenham and Market'
    LocationParser.new([ 'CHARLES J BRENHAM' ]).parse(text).should ==
      [ Intersection.new text, 'Charles J. Brenham', nil, 'Market', nil ]
  end

  [ ' Jr', ', Jr', ' Junior', ', Junior' ].each do |title|
    it "accepts #{title}" do
      text = "Colin P Kelly#{title} at Townsend"
      LocationParser.new([ 'COLIN P KELLY JR' ]).parse(text).should ==
        [ Intersection.new text, "Colin P Kelly#{title}", nil, 'Townsend', nil ]
    end
  end

  it "treats an unknown multi-word name as a series of single words" do
    LocationParser.new([]).parse('26th and San Jose').should == [ Intersection.new '26th and San', '26th', nil, 'San', nil ]
  end

  it "finds multiple locations" do
    LocationParser.new([]).parse('25th and Valencia 26th and Valencia').should ==
      [ Intersection.new('25th and Valencia', '25th', nil, 'Valencia', nil),
        Intersection.new('26th and Valencia', '26th', nil, 'Valencia', nil) ]
  end

  it "finds overlapping locations" do
    LocationParser.new([]).parse('lions and tigers and bears').should ==
      [ Intersection.new('lions and tigers', 'lions', nil, 'tigers', nil),
        Intersection.new('tigers and bears', 'tigers', nil, 'bears', nil) ]
  end

  it "finds a location with a street type" do
    text = '26th St and Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', 'St', 'Valencia', nil ]
  end

end
