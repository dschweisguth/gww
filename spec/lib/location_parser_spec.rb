require 'spec_helper'

describe LocationParser do

  it "finds no Locations in the empty string" do
    parser = LocationParser.new []
    parser.parse('').should == []
  end

  it "finds a Location" do
    parser = LocationParser.new []
    parser.parse('26th and Valencia').should == [ Location.new '26th', 'Valencia' ]
  end

  it "finds a Location with a street with more than one word in its name" do
    parser = LocationParser.new [ 'SAN JOSE' ]
    parser.parse('26th and San Jose').should == [ Location.new '26th', 'San Jose' ]
  end

  it "treats a multi-word name that it doesn't know about as a series of single words" do
    parser = LocationParser.new []
    parser.parse('26th and San Jose').should == [ Location.new '26th', 'San' ]
  end

  it "treats an unwanted multi-word name as a series of single words" do
    parser = LocationParser.new [ 'UNNAMED 1' ]
    parser.parse('Unnamed 1 and Valencia').should == [ Location.new '1', 'Valencia' ]
  end

end
