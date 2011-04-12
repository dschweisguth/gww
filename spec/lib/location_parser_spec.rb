require 'spec_helper'

describe LocationParser do

  it "finds no locations in the empty string" do
    LocationParser.new([]).parse('').should == []
  end

  it "finds an intersection" do
    text = '26th and Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', nil, 'Valencia', nil ]
  end

  it "tolerates periods and commas around an intersection's connecting word(s)" do
    text = '26th ., and ., Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', nil, 'Valencia', nil ]
  end

  %w{ between bet bet. betw betw. }.each do |between|
    it "finds a block delimited with '#{between}'" do
      text = 'Valencia bet 25th and 26th'
      LocationParser.new([]).parse(text).should == [ Block.new text, 'Valencia', nil, '25th', nil, '26th', nil ]
    end
  end

  it "tolerates periods and commas around a block's connecting words" do
    text = 'Valencia ., between ., 25th ., and ., 26th'
    LocationParser.new([]).parse(text).should == [ Block.new text, 'Valencia', nil, '25th', nil, '26th', nil ]
  end

  it "finds an address without adjacent streets" do
    text = '555 California'
    LocationParser.new([]).parse(text).should == [ Address.new text, '555', 'California', nil ]
  end

  it "finds an address with adjacent streets" do
    text = '555 California between Montgomery and Kearny'
    LocationParser.new([]).parse(text).should == [ Address.new text, '555', 'California', nil ]
  end

  it "finds a location with a street with more than one word in its name" do
    text = '26th and San Jose'
    LocationParser.new([ 'SAN JOSE' ]).parse(text).should == [ Intersection.new text, '26th', nil, 'San Jose', nil ]
  end

  it "treats an unknown multi-word name as a series of single words" do
    LocationParser.new([]).parse('26th and San Jose').should == [ Intersection.new '26th and San', '26th', nil, 'San', nil ]
  end

  it "treats an unwanted multi-word name as a series of single words" do
    LocationParser.new([ 'UNNAMED 1' ]).parse('Unnamed 1 and Valencia').should ==
      [ Intersection.new '1 and Valencia', '1', nil, 'Valencia', nil ]
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

  it "finds a location with a street type followed by a period" do
    text = '26th St. and Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', 'St.', 'Valencia', nil ]
  end

  it "ignores a street type not on a word boundary" do
    LocationParser.new([]).parse('26th Stop and Valencia').should ==
      [ Intersection.new 'Stop and Valencia', 'Stop', nil, 'Valencia', nil ]
  end

end
