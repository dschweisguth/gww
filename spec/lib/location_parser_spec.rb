require 'spec_helper'

describe LocationParser do

  it "finds no locations in the empty string" do
    LocationParser.new([]).parse('').should == []
  end

  it "finds an intersection" do
    text = '26th and Valencia'
    LocationParser.new([]).parse(text).should == [ Intersection.new text, '26th', 'Valencia' ]
  end

  it "finds a block" do
    text = 'Valencia between 25th and 26th'
    LocationParser.new([]).parse(text).should == [Block.new(text, 'Valencia', '25th', '26th') ]
  end

  it "finds a location with a street with more than one word in its name" do
    text = '26th and San Jose'
    LocationParser.new([ 'SAN JOSE' ]).parse(text).should == [ Intersection.new text, '26th', 'San Jose' ]
  end

  it "treats a multi-word name that it doesn't know about as a series of single words" do
    LocationParser.new([]).parse('26th and San Jose').should == [ Intersection.new '26th and San', '26th', 'San' ]
  end

  it "treats an unwanted multi-word name as a series of single words" do
    LocationParser.new([ 'UNNAMED 1' ]).parse('Unnamed 1 and Valencia').should ==
      [ Intersection.new '1 and Valencia', '1', 'Valencia' ]
  end

  it "finds multiple locations" do
    LocationParser.new([]).parse('25th and Valencia 26th and Valencia').should ==
      [ Intersection.new('25th and Valencia', '25th', 'Valencia'), Intersection.new('26th and Valencia', '26th', 'Valencia') ]
  end

  it "finds overlapping locations" do
    LocationParser.new([]).parse('lions and tigers and bears').should ==
      [ Intersection.new('lions and tigers', 'lions', 'tigers'), Intersection.new('tigers and bears', 'tigers', 'bears') ]
  end

end
