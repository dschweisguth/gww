require 'spec_helper'

describe Street do
  describe '.regexp' do
    it "accepts any whitespace in a multiword name" do
      matches 'CHARLES J BRENHAM', "Charles \n J \n Brenham"
    end

    %w{ Saint St St. }.each do |title|
      it "accepts #{title} as an abbreviation for Saint" do
        matches 'SAINT FRANCIS', "#{title} Francis"
      end
    end

    %w{ J J. }.each do |initial|
      it "accepts #{initial} as a middle initial" do
        matches 'CHARLES J BRENHAM', "Charles #{initial} Brenham"
      end
    end

    [ ' Jr', ', Jr', ' Junior', ', Junior' ].each do |title|
      it "accepts '#{title}' as a way of writing Junior" do
        matches 'COLIN P KELLY JR', "Colin P Kelly#{title}"
      end
    end

    def matches(known, text)
      Regexp.new(Street.regexp(known), Regexp::IGNORECASE).should match text
    end

  end

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
