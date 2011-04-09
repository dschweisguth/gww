require 'spec_helper'

describe LocationParser do

  before do
    @parser = LocationParser.new [ '26TH', 'VALENCIA', 'SAN JOSE' ]
  end

  it "extracts the two names of streets at an intersection" do
    @parser.parse('26th and Valencia').should == Location.make_valid('26th', 'Valencia')
  end

  it "extracts a street with more than one word in its name" do
    @parser.parse('26th and San Jose').should == Location.make_valid('26th', 'San Jose')
  end

  it "returns an invalid Location, given the empty string" do
    @parser.parse('').should == Location.make_invalid
  end

end
