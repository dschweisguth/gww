require 'spec_helper'
require 'model_factory'

describe Person do

  describe '#new' do
    VALID_ATTRS = { :flickrid => 'flickrid', :username => 'username' }

    it 'creates a valid object given all required attributes' do
      Person.new(VALID_ATTRS).should be_valid
    end

    it 'creates a valid object if flickrid is missing' do
      Person.new(VALID_ATTRS - :flickrid).should_not be_valid
    end

    it 'creates a valid object if flickrid is blank' do
      Person.new(VALID_ATTRS.merge({ :flickrid => '' })).should_not be_valid
    end

    it 'creates a valid object if username is missing' do
      Person.new(VALID_ATTRS - :username).should_not be_valid
    end

    it 'creates a valid object if username is blank' do
      Person.new(VALID_ATTRS.merge({ :username => '' })).should_not be_valid
    end

  end

  describe '#guesses_per_day' do
    it 'returns a map of person ID to average guesses per day' do
      guess = Guess.create_for_test! :guessed_at => 4.days.ago
      Person.guesses_per_day.should == { guess.person.id => 0.25 }
    end
  end

  describe '#guess_speeds' do
    it 'returns a map of person ID to average seconds to guess' do
      photo = Photo.create_for_test! :dateadded => 5.seconds.ago
      guess = Guess.create_for_test! :photo => photo, :guessed_at => 1.seconds.ago
      Person.guess_speeds.should == { guess.person.id => 4 }
    end
  end

  describe '#be_guessed_speeds' do
    it 'returns a map of person ID to average seconds for their photos to be guessed' do
      photo = Photo.create_for_test! :dateadded => 5.seconds.ago
      Guess.create_for_test! :photo => photo, :guessed_at => 1.seconds.ago
      Person.be_guessed_speeds.should == { photo.person.id => 4 }
    end
  end

  describe '#comments_to_guess' do
    it 'returns a map of person ID to average comments/guess' do
      guessed_at = 10.seconds.ago
      guess = Guess.create_for_test! :guessed_at => guessed_at
      Comment.create_for_test! :prefix => 'guess', :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guessed_at
      Person.comments_to_guess.should == { guess.person.id => 1 }
    end

    it 'ignores comments made after a guess' do
      guessed_at = 10.seconds.ago
      guess = Guess.create_for_test! :guessed_at => guessed_at
      Comment.create_for_test! :prefix => 'guess', :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guessed_at
      Comment.create_for_test! :prefix => 'chitchat', :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username
      Person.comments_to_guess.should == { guess.person.id => 1 }
    end

    it 'ignores comments made by others' do
      guessed_at = 10.seconds.ago
      guess = Guess.create_for_test! :guessed_at => guessed_at
      Comment.create_for_test! :prefix => 'guess', :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guessed_at
      Comment.create_for_test! :prefix => "someone else's guess",
        :photo => guess.photo, :commented_at => 11.seconds.ago
      Person.comments_to_guess.should == { guess.person.id => 1 }
    end

  end

  describe '#comments_to_be_guessed' do
    it 'returns a map of person ID to average # of comments for their photos to be guessed' do
      guessed_at = 10.seconds.ago
      guess = Guess.create_for_test! :guessed_at => guessed_at
      Comment.create_for_test! :prefix => 'guess', :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guessed_at
      Comment.create_for_test! :prefix => 'chitchat', :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username
      Person.comments_to_be_guessed.should == { guess.photo.person.id => 1 }
    end
  end

  describe '#high_scorers' do
    it 'returns the three highest scorers in the given previous # of days' do

      guess = Guess.create_for_test! :prefix => '1', :guessed_at => 1.days.ago.getutc
      Guess.create_for_test! :prefix => '2', :person => guess.person, :guessed_at => 1.days.ago.getutc

      high_scorers = Person.high_scorers 2
      high_scorers.should == [ guess.person ]
      high_scorers[0][:score].should == 2

    end

    it 'ignores guesses made before the reporting period' do
      guess = Guess.create_for_test! :prefix => '1', :guessed_at => 1.days.ago.getutc
      Guess.create_for_test! :prefix => '2', :person => guess.person, :guessed_at => 1.days.ago.getutc
      Guess.create_for_test! :prefix => '3', :person => guess.person, :guessed_at => 3.days.ago.getutc

      high_scorers = Person.high_scorers 2
      high_scorers.should == [ guess.person ]
      high_scorers[0][:score].should == 2

    end

    it 'ignores scores of 1' do
      Guess.create_for_test! :guessed_at => 1.days.ago.getutc
      Person.high_scorers(2).should == []
    end

  end

end
