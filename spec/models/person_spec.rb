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
    now = Time.now.getutc
    poster = Person.create! :flickrid => 'poster_flickrid', :username => 'poster_username'
    photo = Photo.create! :person => poster, :flickrid => 'photo_flickrid',
      :farm => 'farm', :server => 'server', :secret => 'secret',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :mapped => 'false', :game_status => 'unfound', :views => 0
    guesser = Person.create! :flickrid => 'guesser_flickrid', :username => 'guesser_username'
    Guess.create! :photo => photo, :person => guesser,
      :guess_text => "guess text", :guessed_at => 4.days.ago, :added_at => now
    Person.guesses_per_day.should == { guesser.id => 0.25 }
  end

end
