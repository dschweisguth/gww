require 'spec_helper'

describe Person do
  it "should be valid if all required attributes are present" do
    Person.new(:flickrid => 'flickrid', :username => 'username').should be_valid
  end

  it "should not be valid without a flickrid" do
    Person.new(:username => 'username').should_not be_valid
  end

  it "should not be valid without a username" do
    Person.new(:flickrid => 'flickrid').should_not be_valid
  end

end
