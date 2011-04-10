require 'spec_helper'

describe LocationParser do

  it "extracts the two names of streets at an intersection" do
    parser = LocationParser.new [ '26TH', 'VALENCIA', 'SAN JOSE' ]
    parser.parse('26th and Valencia').should == Location.make_valid('26th', 'Valencia')
  end

  it "extracts a street with more than one word in its name" do
    parser = LocationParser.new [ '26TH', 'VALENCIA', 'SAN JOSE' ]
    parser.parse('26th and San Jose').should == Location.make_valid('26th', 'San Jose')
  end

  it "returns an invalid Location, given the empty string" do
    parser = LocationParser.new [ '26TH', 'VALENCIA', 'SAN JOSE' ]
    parser.parse('').should == Location.make_invalid
  end

  it "ignores unwanted multi-word names" do
    parser = LocationParser.new [ 'UNNAMED 1' ]
    parser.parse('Unnamed 1 and Valencia').should == Location.make_valid('1', 'Valencia')
  end

end
