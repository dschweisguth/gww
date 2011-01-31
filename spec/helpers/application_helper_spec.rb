require 'spec_helper'

describe ApplicationHelper do
  describe '#singularize' do
    it 'replaces a plural verb with a singular one' do
      helper.singularize('delete', 1).should == 'deletes'
    end

    it 'leaves the verb alone if the number is other than 1' do
      helper.singularize('delete', 0).should == 'delete'
    end

    irregular_verbs = { 'were' => 'was', 'have' => 'has' }
    irregular_verbs.keys.each do |plural|
      it "singularizes #{plural} to #{irregular_verbs[plural]}" do
        helper.singularize(plural, 1).should == irregular_verbs[plural]
      end
    end

  end
end
