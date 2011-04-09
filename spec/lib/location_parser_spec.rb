require 'spec_helper'

describe LocationParser do

  before do
    @parser = LocationParser.new [ '26TH', 'VALENCIA' ]
  end

  it "extracts the two names of streets at an intersection" do
    @parser.parse('26th and Valencia').should == Location.make_valid('26th', 'Valencia')
  end

  it "returns an invalid Location, given the empty string" do
    @parser.parse('').should == Location.make_invalid
  end

end
