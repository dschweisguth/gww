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
    guess = Guess.create_for_test :guessed_at => 4.days.ago
    Person.guesses_per_day.should == { guess.person.id => 0.25 }
  end

  it "should calculate guess speeds" do
    photo = Photo.create_for_test :dateadded => 5.seconds.ago
    guess = Guess.create_for_test :photo => photo, :guessed_at => 1.seconds.ago
    Person.guess_speeds.should == { guess.person.id => 4 }
  end

  it "should calculate be-guessed speeds" do
    photo = Photo.create_for_test :dateadded => 5.seconds.ago
    Guess.create_for_test :photo => photo, :guessed_at => 1.seconds.ago
    Person.be_guessed_speeds.should == { photo.person.id => 4 }
  end

end
