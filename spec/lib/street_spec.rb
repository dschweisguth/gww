require 'spec_helper'

describe Street do
  describe '#initialize' do
    it "removes punctuation and upcases its name" do
      Street.new("John F. O'Kennedy").name.should == 'JOHN F OKENNEDY'
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
