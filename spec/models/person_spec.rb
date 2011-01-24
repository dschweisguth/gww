require 'spec_helper'

describe Person do
  VALID_ATTRS = { :flickrid => 'flickrid', :username => 'username' }

  it "should be valid if all required attributes are present" do
    Person.new(VALID_ATTRS).should be_valid
  end

  it "should not be valid if flickrid is missing" do
    Person.new(VALID_ATTRS - :flickrid).should_not be_valid
  end

  it "should not be valid if flickrid is blank" do
    Person.new(VALID_ATTRS.merge({ :flickrid => '' })).should_not be_valid
  end

  it "should not be valid if username is missing" do
    Person.new(VALID_ATTRS - :username).should_not be_valid
  end

  it "should not be valid if username is blank" do
    Person.new(VALID_ATTRS.merge({ :username => '' })).should_not be_valid
  end

  it "should calculate guesses per day" do
    guess = Guess.create_for_test
    guess.guessed_at = 4.days.ago
    guess.save!
    Person.guesses_per_day.should == { guess.person.id => 0.25 }
  end

end
