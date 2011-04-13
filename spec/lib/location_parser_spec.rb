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
    LocationParser.new([ 'CHARLES J BRENHAM' ]).parse("Charles \n J \n Brenham and Market").should ==
      [ Intersection.new "Charles \n J \n Brenham and Market", "Charles \n J \n Brenham", nil, 'Market', nil ]
  end

  it "accepts a period after an apparent middle initial" do
    LocationParser.new([ 'CHARLES J BRENHAM' ]).parse('Charles J. Brenham and Market').should ==
      [ Intersection.new 'Charles J. Brenham and Market', 'Charles J. Brenham', nil, 'Market', nil ]
  end

  it "accepts a comma before Jr" do
    LocationParser.new([ 'COLIN P KELLY JR' ]).parse('Colin P Kelly, Jr at Townsend').should ==
      [ Intersection.new 'Colin P Kelly, Jr at Townsend', 'Colin P Kelly, Jr', nil, 'Townsend', nil ]
  end

  it "accepts a period after Jr" do
    LocationParser.new([ 'COLIN P KELLY JR' ]).parse('Colin P Kelly Jr. at Townsend').should ==
      [ Intersection.new 'Colin P Kelly Jr. at Townsend', 'Colin P Kelly Jr.', nil, 'Townsend', nil ]
  end

  it "accepts Junior" do
    LocationParser.new([ 'COLIN P KELLY JR' ]).parse('Colin P Kelly Junior at Townsend').should ==
      [ Intersection.new 'Colin P Kelly Junior at Townsend', 'Colin P Kelly Junior', nil, 'Townsend', nil ]
  end

  it "accepts a comma before Junior" do
    LocationParser.new([ 'COLIN P KELLY JR' ]).parse('Colin P Kelly, Junior at Townsend').should ==
      [ Intersection.new 'Colin P Kelly, Junior at Townsend', 'Colin P Kelly, Junior', nil, 'Townsend', nil ]
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
