require 'spec_helper'

describe StreetType do
  describe '#get' do
    it "finds the type with the given name" do
      StreetType.get('St').should == StreetType.new('ST', true, [ StreetType::Synonym.new('STREET', false) ])
    end

    it "ignores a trailing period" do
      StreetType.get('St.').should == StreetType.new('ST', true, [ StreetType::Synonym.new('STREET', false) ])
    end

    it "finds the type with the given synonym" do
      StreetType.get('Street').should == StreetType.new('ST', true, [ StreetType::Synonym.new('STREET', false) ])
    end

  end

  describe '#regexp' do
    it "matches a type" do
      /^#{StreetType.regexp}/i.should match 'St'
    end

    it "includes a period in the match if the type is an abbreviation" do
      /^#{StreetType.regexp}/i.match('St.')[0].should == 'St.'
    end

    it "doesn't include a period in the match if the type isn't an abbreviation" do
      /^#{StreetType.regexp}/i.match('Way.')[0].should == 'Way'
    end

    it "doesn't match a type not on a word boundary" do
      /^#{StreetType.regexp}/i.should_not match 'Stone'
    end

    it "matches a synonym" do
      /^#{StreetType.regexp}/i.should match 'Street'
    end

    it "includes a period in the match if the synonym is an abbreviation" do
      /^#{StreetType.regexp}/i.match('Wy.')[0].should == 'Wy.'
    end

    it "doesn't include a period in the match if the synonym isn't an abbreviation" do
      /^#{StreetType.regexp}/i.match('Street.')[0].should == 'Street'
    end

    it "doesn't match a synonym not on a word boundary" do
      /^#{StreetType.regexp}/i.should_not match 'Wyoming'
    end

  end

end
