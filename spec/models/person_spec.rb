require 'spec_helper'

describe Person do
  it "should create" do
    Person.create! :flickrid => 'flickrid', :username => 'username'
  end
end
