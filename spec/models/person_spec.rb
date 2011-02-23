require 'spec_helper'
require 'support/model_factory'

describe Person do

  describe '#photos' do
    it { should have_many :photos }
  end

  describe '#guesses' do
    it { should have_many :guesses }
  end

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }

    it 'should handle non-ASCII characters' do
      non_ascii_username = '猫娘/ nekomusume'
      Person.make! :username => non_ascii_username
      Person.all[0].username.should == non_ascii_username
    end

  end

  describe '.all_sorted' do
    it 'sorts by username' do
      create_people_named 'z', 'a'
      should_put_person2_before_person1 'username'
    end

    it 'ignores case' do
      create_people_named 'Z', 'a'
      should_put_person2_before_person1 'username'
    end

    it 'sorts by score' do
      create_people_named 'a', 'z'
      stub_score 1, 2
      stub_post_count 2, 1
      should_put_person2_before_person1 'score'
    end

    it 'sorts by score, post count' do
      create_people_named 'a', 'z'
      stub_score 1, 1
      stub_post_count 1, 2
      should_put_person2_before_person1 'score'
    end

    it 'sorts by score, post count, username' do
      create_people_named 'z', 'a'
      stub_score 1, 1
      stub_post_count 1, 1
      should_put_person2_before_person1 'score'
    end

    it 'sorts by post count' do
      create_people_named 'a', 'z'
      stub_post_count 1, 2
      stub_score 2, 1
      should_put_person2_before_person1 'posts'
    end

    it 'sorts by post count, score' do
      create_people_named 'a', 'z'
      stub_post_count 1, 1
      stub_score 1, 2
      should_put_person2_before_person1 'posts'
    end

    it 'sorts by post count, score, username' do
      create_people_named 'z', 'a'
      stub_post_count 1, 1
      stub_score 1, 1
      should_put_person2_before_person1 'posts'
    end

    it 'sorts by guesses per day' do
      create_people_named 'a', 'z'
      stub(Person).guesses_per_day { { @person1.id => 1, @person2.id => 2 } }
      stub_score 2, 1
      should_put_person2_before_person1 'guesses-per-day'
    end

    it 'sorts by guesses per day, score' do
      create_people_named 'a', 'z'
      stub(Person).guesses_per_day { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 2
      should_put_person2_before_person1 'guesses-per-day'
    end

    it 'sorts by guesses per day, score, username' do
      create_people_named 'z', 'a'
      stub(Person).guesses_per_day { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 1
      should_put_person2_before_person1 'guesses-per-day'
    end

    it 'sorts by posts/guess' do
      create_people_named 'a', 'z'
      stub_post_count 4, 3
      stub_score 4, 1
      should_put_person2_before_person1 'posts-per-guess'
    end

    it 'sorts by posts/guess, post count' do
      create_people_named 'a', 'z'
      stub_post_count 2, 4
      stub_score 1, 2
      should_put_person2_before_person1 'posts-per-guess'
    end

    it 'sorts by posts/guess, post count, username' do
      create_people_named 'z', 'a'
      stub_post_count 1, 1
      stub_score 1, 1
      should_put_person2_before_person1 'posts-per-guess'
    end

    it 'sorts by time-to-guess' do
      create_people_named 'a', 'z'
      stub(Person).guess_speeds { { @person1.id => 1, @person2.id => 2 } }
      stub_score 2, 1
      should_put_person2_before_person1 'time-to-guess'
    end

    it 'sorts by time-to-guess, score' do
      create_people_named 'a', 'z'
      stub(Person).guess_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 2
      should_put_person2_before_person1 'time-to-guess'
    end

    it 'sorts by time-to-guess, score, username' do
      create_people_named 'z', 'a'
      stub(Person).guess_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 1
      should_put_person2_before_person1 'time-to-guess'
    end

    it 'sorts by time-to-be-guessed' do
      create_people_named 'a', 'z'
      stub(Person).be_guessed_speeds { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      should_put_person2_before_person1 'time-to-be-guessed'
    end

    it 'sorts by time-to-be-guessed, post count' do
      create_people_named 'a', 'z'
      stub(Person).be_guessed_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      should_put_person2_before_person1 'time-to-be-guessed'
    end

    it 'sorts by time-to-be-guessed, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).be_guessed_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      should_put_person2_before_person1 'time-to-be-guessed'
    end

    it 'sorts by comments-to-guess' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_guess { { @person1.id => 1, @person2.id => 2 } }
      stub_score 2, 1
      should_put_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-guess, score' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_guess { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 2
      should_put_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-guess, score, username' do
      create_people_named 'z', 'a'
      stub(Person).comments_to_guess { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 1
      should_put_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-be-guessed' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_be_guessed { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      should_put_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by comments-to-be-guessed, post count' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_be_guessed { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      should_put_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by comments-to-be-guessed, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).comments_to_be_guessed { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      should_put_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts the other direction, too' do
      create_people_named 'a', 'z'
      Person.all_sorted('username', '-').should == [ @person2, @person1 ]
    end

    def create_people_named(username1, username2)
      @person1 = Person.make! :label => 1, :username => username1
      @person2 = Person.make! :label => 2, :username => username2
    end

    #noinspection RubyResolve
    def stub_post_count(count1, count2)
      stub(Photo).count(:group => 'person_id') { { @person1.id => count1, @person2.id => count2 } }
    end

    #noinspection RubyResolve
    def stub_score(count1, count2)
      stub(Guess).count(:group => 'person_id') { { @person1.id => count1, @person2.id => count2 } }
    end

    #noinspection RubyResolve
    def should_put_person2_before_person1(sorted_by)
      Person.all_sorted(sorted_by, '+').should == [ @person2, @person1 ]
    end

    it 'explodes if sorted_by is invalid' do
      lambda { Person.all_sorted('hat-size', '+') }.should raise_error ArgumentError
    end

    it 'explodes if order is invalid' do
      lambda { Person.all_sorted('username', '?') }.should raise_error ArgumentError
    end

  end

  describe '.top_guessers' do
    before do
      @report_time = Time.utc(2011, 1, 3)
      @report_day = @report_time.beginning_of_day
    end

    it 'returns a structure of scores by day, week, month and year' do
      expected = expected_periods_for_one_guess_at_report_time
      guess = Guess.make! :guessed_at => @report_time
      (0 .. 3).each { |division| expected[division][0].scores[1] = [ guess.person ] }
      Person.top_guessers(@report_time).should == expected
    end

    it 'handles multiple guesses in the same period' do
      expected = expected_periods_for_one_guess_at_report_time
      guesser = Person.make!
      Guess.make! :label => 1, :person => guesser, :guessed_at => @report_time
      Guess.make! :label => 2, :person => guesser, :guessed_at => @report_time + 1.minute
      (0 .. 3).each { |division| expected[division][0].scores[2] = [ guesser ] }
      Person.top_guessers(@report_time).should == expected
    end

    it 'handles multiple guessers with the same scores in the same periods' do
      expected = expected_periods_for_one_guess_at_report_time
      guess1 = Guess.make! :label => 1, :guessed_at => @report_time
      guess2 = Guess.make! :label => 2, :guessed_at => @report_time
      (0 .. 3).each { |division| expected[division][0].scores[1] = [ guess1.person, guess2.person ] }
      Person.top_guessers(@report_time).should == expected
    end

    #noinspection RubyResolve
    def expected_periods_for_one_guess_at_report_time
      [
        (0 .. 6).map { |i| Period.starting_at @report_day - i.days, 1.day },
        [ Period.new @report_day.beginning_of_week - 1.day, @report_day + 1.day ] +
          (0 .. 4).map { |i| Period.starting_at @report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [ Period.new @report_day.beginning_of_month, @report_day + 1.day ] +
          (0 .. 11).map { |i| Period.starting_at @report_day.beginning_of_month - (i + 1).months, 1.month },
        [ Period.new @report_day.beginning_of_year, @report_day + 1.day ]
      ]
    end

    it 'handles previous years' do
      expected = [
        (0 .. 6).map { |i| Period.starting_at @report_day - i.days, 1.day },
        [ Period.new @report_day.beginning_of_week - 1.day, @report_day + 1.day ] +
          (0 .. 4).map { |i| Period.starting_at @report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [ Period.new @report_day.beginning_of_month, @report_day + 1.day ] +
          (0 .. 11).map { |i| Period.starting_at @report_day.beginning_of_month - (i + 1).months, 1.month },
        [ Period.new(@report_day.beginning_of_year, @report_day + 1.day),
          Period.starting_at(@report_day.beginning_of_year - 1.year, 1.year) ]
      ]
      guess = Guess.make! :guessed_at => Time.utc(2010, 1, 1)
      expected[2][12].scores[1] = [ guess.person ]
      expected[3][1].scores[1] = [ guess.person ]
      Person.top_guessers(@report_time).should == expected
    end

  end

  describe '.standing' do
    it "returns the person's score position" do
      person = Person.make!
      Person.standing(person).should == [ 1, false ]
    end

    it "considers other players' scores" do
      Guess.make!
      person = Person.make!
      Person.standing(person).should == [ 2, false ]
    end

    it "detects ties" do
      guess1 = Guess.make! :label => 1
      Guess.make! :label => 2
      Person.standing(guess1.person).should == [ 1, true ]
    end

  end

  describe '.guesses_per_day' do
    it 'returns a map of person ID to average guesses per day' do
      guess = Guess.make! :guessed_at => 4.days.ago
      Person.guesses_per_day.should == { guess.person.id => 0.25 }
    end
  end

  describe '.guess_speeds' do
    it 'returns a map of person ID to average seconds to guess' do
      now = Time.now
      photo = Photo.make! :dateadded => now - 5
      guess = Guess.make! :photo => photo, :guessed_at => now - 1
      Person.guess_speeds.should == { guess.person.id => 4 }
    end
  end

  describe '.be_guessed_speeds' do
    it 'returns a map of person ID to average seconds for their photos to be guessed' do
      now = Time.now
      photo = Photo.make! :dateadded => now - 5
      Guess.make! :photo => photo, :guessed_at => now - 1
      Person.be_guessed_speeds.should == { photo.person.id => 4 }
    end
  end

  describe '.comments_to_guess' do
    before do
      guessed_at = 10.seconds.ago
      @guess = Guess.make! :guessed_at => guessed_at
      Comment.make! :label => 'guess', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username,
        :commented_at => guessed_at
    end

    it 'returns a map of person ID to average # of comments/guess' do
      returns_expected_map
    end

    it 'ignores comments made after the guess' do
      Comment.make! :label => 'chitchat', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username
      returns_expected_map
    end

    it 'ignores comments made by someone other than the guesser' do
      Comment.make! :label => "someone else's guess",
        :photo => @guess.photo, :commented_at => 11.seconds.ago
      returns_expected_map
    end

    #noinspection RubyResolve
    def returns_expected_map
      Person.comments_to_guess.should == { @guess.person.id => 1 }
    end

  end

  describe '.comments_to_be_guessed' do
    before do
      guessed_at = 10.seconds.ago
      @guess = Guess.make! :guessed_at => guessed_at
      Comment.make! :label => 'guess', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username,
        :commented_at => guessed_at
    end

    it 'returns a map of person ID to average # of comments for their photos to be guessed' do
      returns_expected_map
    end

    it 'ignores comments made after the guess' do
      Comment.make! :label => 'chitchat', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username
      returns_expected_map
    end

    it 'ignores comments made by the poster' do
      Comment.make! :label => 'poster', :photo => @guess.photo,
        :flickrid => @guess.photo.person.flickrid, :username => @guess.photo.person.username,
        :commented_at => 11.seconds.ago
      returns_expected_map
    end

    #noinspection RubyResolve
    def returns_expected_map
      Person.comments_to_be_guessed.should == { @guess.photo.person.id => 1 }
    end

  end

  describe '.high_scorers' do
    it 'returns the three highest scorers in the given previous # of days' do

      guess = Guess.make! :label => '1', :guessed_at => 1.days.ago.getutc
      Guess.make! :label => '2', :person => guess.person, :guessed_at => 1.days.ago.getutc

      high_scorers = Person.high_scorers 2
      high_scorers.should == [ guess.person ]
      high_scorers[0][:score].should == 2

    end

    it 'ignores guesses made before the reporting period' do
      guess = Guess.make! :label => '1', :guessed_at => 1.days.ago.getutc
      Guess.make! :label => '2', :person => guess.person, :guessed_at => 1.days.ago.getutc
      Guess.make! :label => '3', :person => guess.person, :guessed_at => 3.days.ago.getutc

      high_scorers = Person.high_scorers 2
      high_scorers.should == [ guess.person ]
      high_scorers[0][:score].should == 2

    end

    it 'ignores scores of 1' do
      Guess.make! :guessed_at => 1.days.ago.getutc
      Person.high_scorers(2).should == []
    end

  end

  describe '.most_points_in_2010' do
    it 'returns a list of scorers with their scores' do
      guess = Guess.make! :guessed_at => Time.utc(2010)
      top_scorers = Person.most_points_in_2010
      top_scorers.should == [ guess.person ]
      top_scorers[0][:points].should == 1
    end

    it 'ignores guesses made before 2010' do
      Guess.make! :guessed_at => Time.utc(2009)
      Person.most_points_in_2010.should == []
    end

    it 'ignores guesses made after 2010' do
      Guess.make! :guessed_at => Time.utc(2011)
      Person.most_points_in_2010.should == []
    end

    it 'returns only the top 10 scorers' do
      10.times do |i|
        guess = Guess.make! :label => (i.to_s + '_first_point'),
          :guessed_at => Time.utc(2010)
        Guess.make! :label => (i.to_s + '_second_point'),
          :person => guess.person, :guessed_at => Time.utc(2010)
      end
      single_guess = Guess.make! :guessed_at => Time.utc(2010)
      top_scorers = Person.most_points_in_2010
      top_scorers.size.should == 10
      #noinspection RubyResolve
      top_scorers.should_not include(single_guess.person)
    end

  end

  describe '.most_posts_in_2010' do
    it 'returns a lists of posters with their number of posts' do
      post = Photo.make! :dateadded => Time.utc(2010)
      top_posters = Person.most_posts_in_2010
      top_posters.should == [ post.person ]
      top_posters[0][:posts].should == 1
    end

    it 'ignores posts before 2010' do
      Photo.make! :dateadded => Time.utc(2009)
      Person.most_posts_in_2010.should == []
    end

    it 'ignores posts after 2010' do
      Photo.make! :dateadded => Time.utc(2011)
      Person.most_posts_in_2010.should == []
    end

    it 'returns only the top 10 posters' do
      10.times do |i|
        post = Photo.make! :label => (i.to_s + '_first_post'),
          :dateadded => Time.utc(2010)
        Photo.make! :label => (i.to_s + '_second_post'),
          :person => post.person, :dateadded => Time.utc(2010)
      end
      single_post = Photo.make! :dateadded => Time.utc(2010)
      top_posters = Person.most_posts_in_2010
      top_posters.size.should == 10
      #noinspection RubyResolve
      top_posters.should_not include(single_post.person)
    end

  end

  describe '.rookies_with_most_points_in_2010' do
    it 'returns a list of rookies with their score' do
      guess = Guess.make! :guessed_at => Time.utc(2010)
      top_scorers = Person.rookies_with_most_points_in_2010
      top_scorers.should == [ guess.person ]
      top_scorers[0][:points].should == 1
    end

    it 'ignores people who guessed before 2010' do
      Guess.make! :guessed_at => Time.utc(2009)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'ignores people who guessed for the first time in 2010 but posted for the first time before 2010' do
      guess = Guess.make! :guessed_at => Time.utc(2010)
      Photo.make! :label => 'before',
        :person => guess.person, :dateadded => Time.utc(2009)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'ignores guesses made after 2010' do
      Guess.make! :guessed_at => Time.utc(2011)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'ignores people who posted for the first time in 2010 but guessed for the first time after 2010' do
      post = Photo.make! :dateadded => Time.utc(2010)
      Guess.make! :label => 'after',
        :person => post.person, :guessed_at => Time.utc(2011)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'returns only the top 10 rookie scorers' do
      10.times do |i|
        guess = Guess.make! :label => (i.to_s + '_first_point'),
          :guessed_at => Time.utc(2010)
        Guess.make! :label => (i.to_s + '_second_point'),
          :person => guess.person, :guessed_at => Time.utc(2010)
      end
      single_guess = Guess.make! :guessed_at => Time.utc(2010)
      top_scorers = Person.rookies_with_most_points_in_2010
      top_scorers.size.should == 10
      #noinspection RubyResolve
      top_scorers.should_not include(single_guess.person)
    end

  end

  describe '.rookies_with_most_posts_in_2010' do
    it 'returns a list of rookies with their number of posts' do
      post = Photo.make! :dateadded => Time.utc(2010)
      top_posters = Person.rookies_with_most_posts_in_2010
      top_posters.should == [ post.person ]
      top_posters[0][:posts].should == 1
    end

    it 'ignores people who posted before 2010' do
      Photo.make! :dateadded => Time.utc(2009)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'ignores people who posted for the first time in 2010 but guessed for the first time before 2010' do
      post = Photo.make! :dateadded => Time.utc(2010)
      Guess.make! :label => 'before',
        :person => post.person, :guessed_at => Time.utc(2009)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'ignores posts made after 2010' do
      Photo.make! :dateadded => Time.utc(2011)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'ignores people who guessed for the first time in 2010 but posted for the first time after 2010' do
      guess = Guess.make! :guessed_at => Time.utc(2010)
      Photo.make! :label => 'after',
        :person => guess.person, :dateadded => Time.utc(2011)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'returns only the top 10 rookie posters' do
      10.times do |i|
        post = Photo.make! :label => (i.to_s + '_first_post'),
          :dateadded => Time.utc(2010)
        Photo.make! :label => (i.to_s + '_second_post'),
          :person => post.person, :dateadded => Time.utc(2010)
      end
      single_post = Photo.make! :dateadded => Time.utc(2010)
      top_posters = Person.rookies_with_most_posts_in_2010
      top_posters.size.should == 10
      #noinspection RubyResolve
      top_posters.should_not include(single_post.person)
    end

  end

  describe '.by_score' do
    it "groups people by score and adds each's post count" do
      person1 = Person.make! :label => 1
      person2 = Person.make! :label => 2
      Person.by_score([ person1, person2 ]).should == {0 => [ person1, person2 ] }
    end

    it 'adds up guesses' do
      person = Person.make!
      Guess.make! :label => 1, :person => person
      Guess.make! :label => 2, :person => person
      Person.by_score([ person ]).should == { 2 => [ person ] }
    end

  end

  describe '#favorite_posters' do
    it "lists the posters which this person has guessed #{Person::MIN_BIAS_FOR_FAVORITE} or more times as often as this person has guessed all posts" do
      guesser, favorite_poster = make_potential_favorite_poster(10, 15)
      favorite_posters = guesser.favorite_posters
      favorite_posters.should == [ favorite_poster ]
      favorite_posters[0][:bias].should == Person::MIN_BIAS_FOR_FAVORITE
    end

    it "ignores a poster which this person has guessed less than #{Person::MIN_BIAS_FOR_FAVORITE} times as often as this person has guessed all posts" do
      #noinspection RubyUnusedLocalVariable
      guesser, favorite_poster = make_potential_favorite_poster(10, 14)
      guesser.favorite_posters.should == []
    end

    it "ignores a poster which this person has guessed less than 10 times" do
      #noinspection RubyUnusedLocalVariable
      guesser, favorite_poster = make_potential_favorite_poster(9, 15)
      guesser.favorite_posters.should == []
    end

  end

  describe '#favorite_posters_of' do
    it "lists the guessers who have guessed this person #{Person::MIN_BIAS_FOR_FAVORITE} or more times as often as those guessers have guessed all posts" do
      devoted_guesser, poster = make_potential_favorite_poster(10, 15)
      favorite_posters_of = poster.favorite_posters_of
      favorite_posters_of.should == [ devoted_guesser ]
      favorite_posters_of[0][:bias].should == Person::MIN_BIAS_FOR_FAVORITE
    end

    it "ignores a guesser who has guessed this person less than #{Person::MIN_BIAS_FOR_FAVORITE} times as often as that guesser has guessed all posts" do
      #noinspection RubyUnusedLocalVariable
      devoted_guesser, poster = make_potential_favorite_poster(10, 14)
      poster.favorite_posters_of.should == []
    end

    it "ignores a guesser who has guessed this person less than 10 times" do
      #noinspection RubyUnusedLocalVariable
      devoted_guesser, poster = make_potential_favorite_poster(9, 15)
      poster.favorite_posters_of.should == []
    end
    
  end

  def make_potential_favorite_poster(posts_by_favorite, posts_by_others)
    favorite_poster = Person.make! :label => 'favorite_poster'
    devoted_guesser = Person.make! :label => 'devoted_guesser'
    (1 .. posts_by_favorite).each do |n|
      photo = Photo.make! :label => n, :person => favorite_poster
      Guess.make! :label => n, :person => devoted_guesser, :photo => photo
    end
    other_poster = Person.make! :label => 'other_poster'
    ((posts_by_favorite + 1) .. (posts_by_favorite + posts_by_others)).each do |n|
      Photo.make! :label => n, :person => other_poster
    end
    return devoted_guesser, favorite_poster
  end

  describe '#destroy_if_has_no_dependents' do
    it 'destroys the person' do
      person = Person.make!
      person.destroy_if_has_no_dependents
      Person.count.should == 0
    end

    it 'but not if they have a photo' do
      person = Person.make!
      Photo.make! :person => person
      person.destroy_if_has_no_dependents
      Person.all.should == [ person ]
    end

    it 'but not if they have a guess' do
      person = Person.make!
      Guess.make! :person => person
      person.destroy_if_has_no_dependents
      Person.find(person.id).should == person
    end

  end

end
