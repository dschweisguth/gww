require 'spec_helper'

describe ApplicationHelper do
  describe '#singularize' do
    it 'replaces a plural verb with a singular one' do
      helper.singularize('delete', 1).should == 'deletes'
    end

    it 'leaves the verb alone if the number is other than 1' do
      helper.singularize('delete', 0).should == 'delete'
    end

    irregular_plural_verbs = { 'were' => 'was', 'have' => 'has' }
    irregular_plural_verbs.keys.each do |plural|
      it "singularizes the irregular plural verb #{plural} to #{irregular_plural_verbs[plural]}" do
        helper.singularize(plural, 1).should == irregular_plural_verbs[plural]
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

end
