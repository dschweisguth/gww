require 'spec_helper'

describe Street do
  describe '#initialize' do
    it "upcases its name" do
      Street.new('Valencia').name.should == 'VALENCIA'
    end

    it "canonicalizes a synonym" do
      Street.new('DeHaro').name.should == 'DE HARO'
    end

    it "converts a string street type to a real one" do
      Street.new('Valencia', 'St').type.should == StreetType.get('St')
    end

    it "ignores whitespace around the input street type" do
      Street.new('Valencia', ' St ').type.should == StreetType.get('St')
    end

  end
end
