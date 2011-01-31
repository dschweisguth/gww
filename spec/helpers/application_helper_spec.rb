require 'spec_helper'

describe ApplicationHelper do
  describe '#singularize' do
    it 'replaces a plural verb with a singular one' do
      helper.singularize('delete', 1).should == 'deletes'
    end

    it 'leaves the verb alone if the number is other than 1' do
      helper.singularize('delete', 0).should == 'delete'
    end

    expected = { 'were' => 'was', 'have' => 'has' }
    expected.keys.each do |plural|
      it "singularizes the irregular plural verb #{plural} to #{expected[plural]}" do
        helper.singularize(plural, 1).should == expected[plural]
      end
    end

  end

  describe '#ordinal' do
    expected = {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      4 => '4th',
      11 => '11th',
      12 => '12th',
      13 => '13th',
      21 => '21st',
      22 => '22nd',
      23 => '23rd'
    }
    expected.keys.sort.each do |cardinal|
      it "converts the number #{cardinal} to its ordinal, #{expected[cardinal]}" do
        helper.ordinal(cardinal).should == expected[cardinal]
      end
    end
  end

  describe '#local_date' do
    it 'returns the local time as yyyy/mm/dd' do
      helper.local_date(Time.utc(2011)).should == '2010/12/31'
    end
  end

  describe '#link_to_person' do
    it 'returns a local link to the person' do
      person = Person.create_for_test!
      helper.link_to_person(person).should ==
        "<a href=\"/people/show/#{person.id}\">username</a>"
    end

    it 'escapes HTML special characters in the username' do
      person = Person.create_for_test! :username => 'tom&jerry'
      helper.link_to_person(person).should ==
        "<a href=\"/people/show/#{person.id}\">tom&amp;jerry</a>"
    end

  end

end
