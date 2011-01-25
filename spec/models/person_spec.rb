require 'spec_helper'
require 'model_factory'

describe Person do

  describe '.new' do
    VALID_ATTRS = { :flickrid => 'flickrid', :username => 'username' }

    it 'creates a valid object given all required attributes' do
      Person.new(VALID_ATTRS).should be_valid
    end

    it 'creates an invalid object if flickrid is missing' do
      Person.new(VALID_ATTRS - :flickrid).should_not be_valid
    end

    it 'creates an invalid object if flickrid is blank' do
      Person.new(VALID_ATTRS.merge({ :flickrid => '' })).should_not be_valid
    end

    it 'creates an invalid object if username is missing' do
      Person.new(VALID_ATTRS - :username).should_not be_valid
    end

    it 'creates an invalid object if username is blank' do
      Person.new(VALID_ATTRS.merge({ :username => '' })).should_not be_valid
    end

  end

  describe '.guesses_per_day' do
    it 'returns a map of person ID to average guesses per day' do
      guess = Guess.create_for_test! :guessed_at => 4.days.ago
      Person.guesses_per_day.should == { guess.person.id => 0.25 }
    end
  end

  describe '.guess_speeds' do
    it 'returns a map of person ID to average seconds to guess' do
      photo = Photo.create_for_test! :dateadded => 5.seconds.ago
      guess = Guess.create_for_test! :photo => photo, :guessed_at => 1.seconds.ago
      Person.guess_speeds.should == { guess.person.id => 4 }
    end
  end

  describe '.be_guessed_speeds' do
    it 'returns a map of person ID to average seconds for their photos to be guessed' do
      photo = Photo.create_for_test! :dateadded => 5.seconds.ago
      Guess.create_for_test! :photo => photo, :guessed_at => 1.seconds.ago
      Person.be_guessed_speeds.should == { photo.person.id => 4 }
    end
  end

  describe '.comments_to_guess' do
    before do
      guessed_at = 10.seconds.ago
      @guess = Guess.create_for_test! :guessed_at => guessed_at
      Comment.create_for_test! :prefix => 'guess', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username,
        :commented_at => guessed_at
    end

    it 'returns a map of person ID to average # of comments/guess' do
      returns_expected_map
    end

    it 'ignores comments made after a guess' do
      Comment.create_for_test! :prefix => 'chitchat', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username
      returns_expected_map
    end

    it 'ignores comments made by others' do
      Comment.create_for_test! :prefix => "someone else's guess",
        :photo => @guess.photo, :commented_at => 11.seconds.ago
      returns_expected_map
    end

    #noinspection RubyResolve
    def returns_expected_map
      Person.comments_to_guess.should == { @guess.person.id => 1 }
    end

  end

  describe '.comments_to_be_guessed' do
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

  describe '.high_scorers' do
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

  describe '.most_points_in_2010' do
    context 'given a single scorer in 2010' do
      before do
        @guess = Guess.create_for_test! :guessed_at => Time.utc(2010)
      end

      it 'returns that scorer with their score' do
        returns_single_scorer_with_score
      end

      it 'ignores guesses made before 2010' do
        Guess.create_for_test! :prefix => 'before', :guessed_at => Time.utc(2009)
        returns_single_scorer_with_score
      end

      it 'ignores guesses made after 2010' do
        Guess.create_for_test! :prefix => 'after', :guessed_at => Time.utc(2011)
        returns_single_scorer_with_score
      end

      #noinspection RubyResolve
      def returns_single_scorer_with_score
        high_scorers = Person.most_points_in_2010
        high_scorers.should == [ @guess.person ]
        high_scorers[0][:points].should == 1
      end
    end

    context 'given more than 10 scorers in 2010' do
      it 'returns only the top 10' do
        10.times do |i|
          guess = Guess.create_for_test! :prefix => (i.to_s + '_first_point'),
            :guessed_at => Time.utc(2010)
          Guess.create_for_test! :prefix => (i.to_s + '_second_point'),
            :person => guess.person, :guessed_at => Time.utc(2010)
        end
        single_guess = Guess.create_for_test! :guessed_at => Time.utc(2010)
        high_scorers = Person.most_points_in_2010
        high_scorers.size.should == 10
        high_scorers.should_not include(single_guess.person)
      end
    end

  end

  describe '.most_posts_in_2010' do
    context 'given a single poster in 2010' do
      before do
        @post = Photo.create_for_test! :dateadded => Time.utc(2010)
      end

      it 'returns that poster with their number of posts' do
        returns_single_poster_with_post
      end

      #noinspection RubyResolve
      def returns_single_poster_with_post
        top_posters = Person.most_posts_in_2010
        top_posters.should == [ @post.person ]
        top_posters[0][:posts].should == 1
      end

    end
  end

end
