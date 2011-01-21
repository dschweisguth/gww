require 'spec_helper'

describe Person do
  VALID_ATTRS = { :flickrid => 'flickrid', :username => 'username' }

  it "should be valid if all required attributes are present" do
    Person.new(VALID_ATTRS).should be_valid
  end

  it "should not be valid without a flickrid" do
    Person.new(VALID_ATTRS - :flickrid).should_not be_valid
  end

  it "should not be valid without a username" do
    Person.new(VALID_ATTRS - :username).should_not be_valid
  end

end
