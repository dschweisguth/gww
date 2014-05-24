require 'spec_helper'

describe ActiveRecord::Base do
  describe '.only_one_exists' do
    it "returns the only instance of the object of the class that the method is called on" do
      stub(Person).all { [1] }
      Person.only_one_exists.should == 1
    end

    it "fails the example if there is a number of objects of that class other than 1" do
      stub(Person).all { [1, 2] }
      lambda { Person.only_one_exists }.should raise_error(
        RSpec::Expectations::ExpectationNotMetError, "Expected there to be only 1 Person instance, but there are 2")
    end

  end
end
