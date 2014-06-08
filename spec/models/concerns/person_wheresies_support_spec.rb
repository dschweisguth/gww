require 'spec_helper'

describe Person do
  describe '.most_points_in' do
    it 'returns a list of scorers with their scores' do
      guess = create :guess, commented_at: Time.local(2010).getutc
      top_scorers = Person.most_points_in 2010
      top_scorers.should == [ guess.person ]
      top_scorers[0].points.should == 1
    end

    it 'ignores guesses made before the given year' do
      create :guess, commented_at: Time.local(2009).getutc
      Person.most_points_in(2010).should == []
    end

    it 'ignores guesses made after the given year' do
      create :guess, commented_at: Time.local(2011).getutc
      Person.most_points_in(2010).should == []
    end

    it 'returns only the top 10 scorers' do
      10.times do
        guess = create :guess, commented_at: Time.local(2010).getutc
        create :guess, person: guess.person, commented_at: Time.local(2010).getutc
      end
      single_guess = create :guess, commented_at: Time.local(2010).getutc
      top_scorers = Person.most_points_in 2010
      top_scorers.size.should == 10
      top_scorers.should_not include(single_guess.person)
    end

  end

  describe '.most_posts_in' do
    it 'returns a lists of posters with their number of posts' do
      post = create :photo, dateadded: Time.local(2010).getutc
      top_posters = Person.most_posts_in 2010
      top_posters.should == [ post.person ]
      top_posters[0].post_count.should == 1
    end

    it 'ignores posts before the given year' do
      create :photo, dateadded: Time.local(2009).getutc
      Person.most_posts_in(2010).should == []
    end

    it 'ignores posts after the given year' do
      create :photo, dateadded: Time.local(2011).getutc
      Person.most_posts_in(2010).should == []
    end

    it 'returns only the top 10 posters' do
      10.times do
        post = create :photo, dateadded: Time.local(2010).getutc
        create :photo, person: post.person, dateadded: Time.local(2010).getutc
      end
      single_post = create :photo, dateadded: Time.local(2010).getutc
      top_posters = Person.most_posts_in 2010
      top_posters.size.should == 10
      #noinspection RubyResolve
      top_posters.should_not include(single_post.person)
    end

  end

  describe '.rookies_with_most_points_in' do
    it 'returns a list of rookies with their score' do
      guess = create :guess, commented_at: Time.local(2010).getutc
      top_scorers = Person.rookies_with_most_points_in 2010
      top_scorers.should == [ guess.person ]
      top_scorers[0].points.should == 1
    end

    it 'ignores people who guessed before the given year' do
      create :guess, commented_at: Time.local(2009).getutc
      Person.rookies_with_most_points_in(2010).should == []
    end

    it 'ignores people who guessed for the first time in the given year but posted for the first time before the given year' do
      guess = create :guess, commented_at: Time.local(2010).getutc
      create :photo, person: guess.person, dateadded: Time.local(2009).getutc
      Person.rookies_with_most_points_in(2010).should == []
    end

    it 'ignores guesses made after the given year' do
      create :guess, commented_at: Time.local(2011).getutc
      Person.rookies_with_most_points_in(2010).should == []
    end

    it 'ignores people who posted for the first time in the given year but guessed for the first time after the given year' do
      post = create :photo, dateadded: Time.local(2010).getutc
      create :guess, person: post.person, commented_at: Time.local(2011).getutc
      Person.rookies_with_most_points_in(2010).should == []
    end

    it 'returns only the top 10 rookie scorers' do
      10.times do
        guess = create :guess, commented_at: Time.local(2010).getutc
        create :guess, person: guess.person, commented_at: Time.local(2010).getutc
      end
      single_guess = create :guess, commented_at: Time.local(2010).getutc
      top_scorers = Person.rookies_with_most_points_in 2010
      top_scorers.size.should == 10
      #noinspection RubyResolve
      top_scorers.should_not include(single_guess.person)
    end

  end

  describe '.rookies_with_most_posts_in' do
    it 'returns a list of rookies with their number of posts' do
      post = create :photo, dateadded: Time.local(2010).getutc
      top_posters = Person.rookies_with_most_posts_in 2010
      top_posters.should == [ post.person ]
      top_posters[0].post_count.should == 1
    end

    it 'ignores people who posted before the given year' do
      create :photo, dateadded: Time.local(2009).getutc
      Person.rookies_with_most_posts_in(2010).should == []
    end

    it 'ignores people who posted for the first time in the given year but guessed for the first time before the given year' do
      post = create :photo, dateadded: Time.local(2010).getutc
      create :guess, person: post.person, commented_at: Time.local(2009).getutc
      Person.rookies_with_most_posts_in(2010).should == []
    end

    it 'ignores posts made after the given year' do
      create :photo, dateadded: Time.local(2011).getutc
      Person.rookies_with_most_posts_in(2010).should == []
    end

    it 'ignores people who guessed for the first time in the given year but posted for the first time after the given year' do
      guess = create :guess, commented_at: Time.local(2010).getutc
      create :photo, person: guess.person, dateadded: Time.local(2011).getutc
      Person.rookies_with_most_posts_in(2010).should == []
    end

    it 'returns only the top 10 rookie posters' do
      10.times do
        post = create :photo, dateadded: Time.local(2010).getutc
        create :photo, person: post.person, dateadded: Time.local(2010).getutc
      end
      single_post = create :photo, dateadded: Time.local(2010).getutc
      top_posters = Person.rookies_with_most_posts_in 2010
      top_posters.size.should == 10
      #noinspection RubyResolve
      top_posters.should_not include(single_post.person)
    end

  end

end
