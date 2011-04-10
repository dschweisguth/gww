require 'spec_helper'

describe LocationParser do

  it "finds no Locations in the empty string" do
    LocationParser.new([]).parse('').should == []
  end

  it "finds a Location" do
    LocationParser.new([]).parse('26th and Valencia').should == [ Location.new '26th', 'Valencia' ]
  end

  it "finds a Location with a street with more than one word in its name" do
    LocationParser.new([ 'SAN JOSE' ]).parse('26th and San Jose').should == [ Location.new '26th', 'San Jose' ]
  end

  it "treats a multi-word name that it doesn't know about as a series of single words" do
    LocationParser.new([]).parse('26th and San Jose').should == [ Location.new '26th', 'San' ]
  end

  it "treats an unwanted multi-word name as a series of single words" do
    LocationParser.new([ 'UNNAMED 1' ]).parse('Unnamed 1 and Valencia').should == [ Location.new '1', 'Valencia' ]
  end

end
