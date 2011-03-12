require 'spec_helper'

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
      Person.make :username => non_ascii_username
      Person.all[0].username.should == non_ascii_username
    end

  end

  describe '.find' do
    before do
      @person = Person.make
    end

    it 'finds a person by username' do
      Person.find_by_multiple_fields(@person.username).should == @person
    end

    it 'finds a person by flickrid' do
      Person.find_by_multiple_fields(@person.flickrid).should == @person
    end

    it 'finds a person by GWW ID' do
      Person.find_by_multiple_fields(@person.id.to_s).should == @person
    end

    it 'punts back to the home page' do
      Person.find_by_multiple_fields('xxx').should be_nil
    end

  end

  describe '.all_sorted' do
    it 'sorts by username' do
      create_people_named 'z', 'a'
      puts_person2_before_person1 'username'
    end

    it 'ignores case' do
      create_people_named 'Z', 'a'
      puts_person2_before_person1 'username'
    end

    it 'sorts by score' do
      create_people_named 'a', 'z'
      stub_score 1, 2
      stub_post_count 2, 1
      puts_person2_before_person1 'score'
    end

    it 'sorts by score, post count' do
      create_people_named 'a', 'z'
      stub_score 1, 1
      stub_post_count 1, 2
      puts_person2_before_person1 'score'
    end

    it 'sorts by score, post count, username' do
      create_people_named 'z', 'a'
      stub_score 1, 1
      stub_post_count 1, 1
      puts_person2_before_person1 'score'
    end

    it 'sorts by post count' do
      create_people_named 'a', 'z'
      stub_post_count 1, 2
      stub_score 2, 1
      puts_person2_before_person1 'posts'
    end

    it 'sorts by post count, score' do
      create_people_named 'a', 'z'
      stub_post_count 1, 1
      stub_score 1, 2
      puts_person2_before_person1 'posts'
    end

    it 'sorts by post count, score, username' do
      create_people_named 'z', 'a'
      stub_post_count 1, 1
      stub_score 1, 1
      puts_person2_before_person1 'posts'
    end

    it "sorts by score + post count, even when that's different from score alone" do
      create_people_named 'a', 'z'
      stub_score 1, 0
      stub_post_count 1, 3
      puts_person2_before_person1 'score-plus-posts'
    end

    it "sorts by score + post count, even when that's different from post count alone" do
      create_people_named 'a', 'z'
      stub_score 1, 3
      stub_post_count 1, 0
      puts_person2_before_person1 'score-plus-posts'
    end

    it "sorts by score + post count, score" do
      create_people_named 'a', 'z'
      stub_score 1, 2
      stub_post_count 1, 0
      puts_person2_before_person1 'score-plus-posts'
    end

    it "sorts by score + post count, score, username" do
      create_people_named 'z', 'a'
      stub_score 1, 1
      stub_post_count 1, 1
      puts_person2_before_person1 'score-plus-posts'
    end

    it 'sorts by guesses per day' do
      create_people_named 'a', 'z'
      stub(Person).guesses_per_day { { @person1.id => 1, @person2.id => 2 } }
      stub_score 2, 1
      puts_person2_before_person1 'guesses-per-day'
    end

    it 'sorts by guesses per day, score' do
      create_people_named 'a', 'z'
      stub(Person).guesses_per_day { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 2
      puts_person2_before_person1 'guesses-per-day'
    end

    it 'sorts by guesses per day, score, username' do
      create_people_named 'z', 'a'
      stub(Person).guesses_per_day { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 1
      puts_person2_before_person1 'guesses-per-day'
    end

    it 'sorts by posts per day' do
      create_people_named 'a', 'z'
      stub(Person).posts_per_day { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      puts_person2_before_person1 'posts-per-day'
    end

    it 'sorts by posts per day, post count' do
      create_people_named 'a', 'z'
      stub(Person).posts_per_day { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      puts_person2_before_person1 'posts-per-day'
    end

    it 'sorts by posts per day, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).posts_per_day { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      puts_person2_before_person1 'posts-per-day'
    end

    it 'sorts by posts/guess' do
      create_people_named 'a', 'z'
      stub_post_count 4, 3
      stub_score 4, 1
      puts_person2_before_person1 'posts-per-guess'
    end

    it 'sorts by posts/guess, post count' do
      create_people_named 'a', 'z'
      stub_post_count 2, 4
      stub_score 1, 2
      puts_person2_before_person1 'posts-per-guess'
    end

    it 'sorts by posts/guess, post count, username' do
      create_people_named 'z', 'a'
      stub_post_count 1, 1
      stub_score 1, 1
      puts_person2_before_person1 'posts-per-guess'
    end

    it 'sorts by time-to-guess' do
      create_people_named 'a', 'z'
      stub(Person).guess_speeds { { @person1.id => 1, @person2.id => 2 } }
      stub_score 2, 1
      puts_person2_before_person1 'time-to-guess'
    end

    it 'sorts by time-to-guess, score' do
      create_people_named 'a', 'z'
      stub(Person).guess_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 2
      puts_person2_before_person1 'time-to-guess'
    end

    it 'sorts by time-to-guess, score, username' do
      create_people_named 'z', 'a'
      stub(Person).guess_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 1
      puts_person2_before_person1 'time-to-guess'
    end

    it 'sorts by time-to-be-guessed' do
      create_people_named 'a', 'z'
      stub(Person).be_guessed_speeds { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      puts_person2_before_person1 'time-to-be-guessed'
    end

    it 'sorts by time-to-be-guessed, post count' do
      create_people_named 'a', 'z'
      stub(Person).be_guessed_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      puts_person2_before_person1 'time-to-be-guessed'
    end

    it 'sorts by time-to-be-guessed, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).be_guessed_speeds { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      puts_person2_before_person1 'time-to-be-guessed'
    end

    it 'sorts by comments-to-guess' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_guess { { @person1.id => 1, @person2.id => 2 } }
      stub_score 2, 1
      puts_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-guess, score' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_guess { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 2
      puts_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-guess, score, username' do
      create_people_named 'z', 'a'
      stub(Person).comments_to_guess { { @person1.id => 1, @person2.id => 1 } }
      stub_score 1, 1
      puts_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-per-post' do
      create_people_named 'a', 'z'
      stub(Person).comments_per_post { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      puts_person2_before_person1 'comments-per-post'
    end

    it 'sorts by comments-per-post, post count' do
      create_people_named 'a', 'z'
      stub(Person).comments_per_post { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      puts_person2_before_person1 'comments-per-post'
    end

    it 'sorts by comments-per-post, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).comments_per_post { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      puts_person2_before_person1 'comments-per-post'
    end

    it 'sorts by comments-to-be-guessed' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_be_guessed { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      puts_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by comments-to-be-guessed, post count' do
      create_people_named 'a', 'z'
      stub(Person).comments_to_be_guessed { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      puts_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by comments-to-be-guessed, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).comments_to_be_guessed { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      puts_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts the other direction, too' do
      create_people_named 'a', 'z'
      Person.all_sorted('username', '-').should == [ @person2, @person1 ]
    end

    def create_people_named(username1, username2)
      @person1 = Person.make 1, :username => username1
      @person2 = Person.make 2, :username => username2
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
    def puts_person2_before_person1(sorted_by)
      Person.all_sorted(sorted_by, '+').should == [ @person2, @person1 ]
    end

    it 'explodes if sorted_by is invalid' do
      lambda { Person.all_sorted('hat-size', '+') }.should raise_error ArgumentError
    end

    it 'explodes if order is invalid' do
      lambda { Person.all_sorted('username', '?') }.should raise_error ArgumentError
    end

  end

  describe '.nemeses' do
    it "lists guessers and their favorite posters" do
      guesser, favorite_poster = make_potential_favorite_poster(10, 15)
      nemeses = Person.nemeses
      nemeses.should == [ guesser ]
      nemesis = nemeses[0]
      nemesis[:poster].should == favorite_poster
      nemesis[:bias].should == 2.5
    end

    it "ignores less than #{Person::MIN_GUESSES_FOR_FAVORITE} guesses" do
      make_potential_favorite_poster(9, 15)
      Person.nemeses.should == []
    end

  end

  describe '.top_guessers' do
    before do
      @report_time = Time.local(2011, 1, 3)
      @report_day = @report_time.beginning_of_day
    end

    it 'returns a structure of scores by day, week, month and year' do
      expected = expected_periods_for_one_guess_at_report_time
      guess = Guess.make :guessed_at => @report_time
      (0 .. 3).each { |division| expected[division][0].scores[1] = [ guess.person ] }
      Person.top_guessers(@report_time).should == expected
    end

    it 'handles multiple guesses in the same period' do
      expected = expected_periods_for_one_guess_at_report_time
      guesser = Person.make
      Guess.make 1, :person => guesser, :guessed_at => @report_time
      Guess.make 2, :person => guesser, :guessed_at => @report_time + 1.minute
      (0 .. 3).each { |division| expected[division][0].scores[2] = [ guesser ] }
      Person.top_guessers(@report_time).should == expected
    end

    it 'handles multiple guessers with the same scores in the same periods' do
      expected = expected_periods_for_one_guess_at_report_time
      guess1 = Guess.make 1, :guessed_at => @report_time
      guess2 = Guess.make 2, :guessed_at => @report_time
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
      guess = Guess.make :guessed_at => Time.local(2010, 1, 1).getutc
      expected[2][12].scores[1] = [ guess.person ]
      expected[3][1].scores[1] = [ guess.person ]
      Person.top_guessers(@report_time).should == expected
    end

  end

  describe '.standing' do
    it "returns the person's score position" do
      person = Person.make
      Person.standing(person).should == [ 1, false ]
    end

    it "considers other players' scores" do
      Guess.make
      person = Person.make
      Person.standing(person).should == [ 2, false ]
    end

    it "detects ties" do
      guess1 = Guess.make 1
      Guess.make 2
      Person.standing(guess1.person).should == [ 1, true ]
    end

  end

  describe '.posts_standing' do
    it "returns the person's post position" do
      person = Person.make
      Person.posts_standing(person).should == [ 1, false ]
    end

    it "considers other players' posts" do
      Photo.make
      person = Person.make
      Person.posts_standing(person).should == [ 2, false ]
    end

    it "detects ties" do
      post1 = Photo.make 1
      Photo.make 2
      Person.posts_standing(post1.person).should == [ 1, true ]
    end

  end

    describe '.guesses_per_day' do
    it 'returns a map of person ID to average guesses per day' do
      guess = Guess.make :guessed_at => 4.days.ago
      Person.guesses_per_day.should == { guess.person.id => 0.25 }
    end
  end

  describe '.posts_per_day' do
    it 'returns a map of person ID to average posts per day' do
      photo = Photo.make :dateadded => 4.days.ago
      Person.posts_per_day.should == { photo.person.id => 0.25 }
    end
  end

  describe '.guess_speeds' do
    it 'returns a map of person ID to average seconds to guess' do
      now = Time.now
      photo = Photo.make :dateadded => now - 5
      guess = Guess.make :photo => photo, :guessed_at => now - 1
      Person.guess_speeds.should == { guess.person.id => 4 }
    end
  end

  describe '.be_guessed_speeds' do
    it 'returns a map of person ID to average seconds for their photos to be guessed' do
      now = Time.now
      photo = Photo.make :dateadded => now - 5
      Guess.make :photo => photo, :guessed_at => now - 1
      Person.be_guessed_speeds.should == { photo.person.id => 4 }
    end
  end

  describe '.comments_to_guess' do
    before do
      guessed_at = 10.seconds.ago
      @guess = Guess.make :guessed_at => guessed_at
      Comment.make 'guess', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username,
        :commented_at => guessed_at
    end

    it 'returns a map of person ID to average # of comments/guess' do
      returns_expected_map
    end

    it 'ignores comments made after the guess' do
      Comment.make 'chitchat', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username
      returns_expected_map
    end

    it 'ignores comments made by someone other than the guesser' do
      Comment.make "someone else's guess",
        :photo => @guess.photo, :commented_at => 11.seconds.ago
      returns_expected_map
    end

    #noinspection RubyResolve
    def returns_expected_map
      Person.comments_to_guess.should == { @guess.person.id => 1 }
    end

  end

  describe '.comments_per_post' do
    it 'returns a map of person ID to average # of comments on their post' do
      comment = Comment.make
      Person.comments_per_post.should == { comment.photo.person.id => 1 }
    end

    it 'ignores comments made by the poster' do
      photo = Photo.make
      Comment.make :photo => photo, :flickrid => photo.person.flickrid,
        :username => photo.person.username
      Person.comments_per_post.should == {}
    end

  end

  describe '.comments_to_be_guessed' do
    before do
      guessed_at = 10.seconds.ago
      @guess = Guess.make :guessed_at => guessed_at
      Comment.make 'guess', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username,
        :commented_at => guessed_at
    end

    it 'returns a map of person ID to average # of comments for their photos to be guessed' do
      returns_expected_map
    end

    it 'ignores comments made after the guess' do
      Comment.make 'chitchat', :photo => @guess.photo,
        :flickrid => @guess.person.flickrid, :username => @guess.person.username
      returns_expected_map
    end

    it 'ignores comments made by the poster' do
      Comment.make 'poster', :photo => @guess.photo,
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
    before do
      @report_date = Time.utc(2011)
    end

    it "returns the three highest scorers in the given previous # of days" do
      person = Person.make
      Guess.make 1, :person => person, :guessed_at => @report_date, :added_at => @report_date
      Guess.make 2, :person => person, :guessed_at => @report_date, :added_at => @report_date
      high_scorers_returns @report_date, 1, person, 2
    end

    it "ignores guesses made before the reporting period" do
      person = Person.make
      Guess.make 1, :person => person, :guessed_at => @report_date, :added_at => @report_date
      Guess.make 2, :person => person, :guessed_at => @report_date, :added_at => @report_date
      Guess.make 3, :person => person, :guessed_at => @report_date - 1.day - 1.second, :added_at => @report_date
      high_scorers_returns @report_date, 1, person, 2
    end

    it "ignores guesses added after the reporting period" do
      person = Person.make
      Guess.make 1, :person => person, :guessed_at => @report_date, :added_at => @report_date
      Guess.make 2, :person => person, :guessed_at => @report_date, :added_at => @report_date
      Guess.make 3, :person => person, :guessed_at => @report_date, :added_at => @report_date + 1.second
      high_scorers_returns @report_date, 1, person, 2
    end

    def high_scorers_returns(now, for_the_past_n_days, person, score)
      high_scorers = Person.high_scorers now, for_the_past_n_days
      high_scorers.should == [ person ]
      high_scorers[0][:score].should == score
    end

    it "ignores scores of 1" do
      Guess.make :guessed_at => @report_date, :added_at => @report_date
      Person.high_scorers(@report_date, 1).should == []
    end

    it "ignores scores of 0" do
      Photo.make
      Person.high_scorers(@report_date, 1).should == []
    end

  end

  describe '.top_posters' do
    before do
      @report_date = Time.utc(2011)
    end

    it "returns the three most frequent posters in the given previous # of days" do
      person = Person.make
      Photo.make 1, :person => person, :dateadded => @report_date
      Photo.make 2, :person => person, :dateadded => @report_date
      top_posters_returns @report_date, 1, person, 2
    end

    it "ignores photos posted before the reporting period" do
      person = Person.make
      Photo.make 1, :person => person, :dateadded => @report_date
      Photo.make 2, :person => person, :dateadded => @report_date
      Photo.make 3, :person => person, :dateadded => @report_date - 1.day - 1.second
      top_posters_returns @report_date, 1, person, 2
    end

    it "ignores photos posted after the reporting period" do
      person = Person.make
      Photo.make 1, :person => person, :dateadded => @report_date
      Photo.make 2, :person => person, :dateadded => @report_date
      Photo.make 3, :person => person, :dateadded => @report_date + 1.second
      top_posters_returns @report_date, 1, person, 2
    end

    def top_posters_returns(now, for_the_past_n_days, person, posts)
      top_posters = Person.top_posters now, for_the_past_n_days
      top_posters.should == [ person ]
      top_posters[0][:posts].should == posts
    end

    it "ignores post counts of 1" do
      Photo.make :dateadded => @report_date
      Person.top_posters(@report_date, 1).should == []
    end

    it "ignores post counts of 0" do
      Person.make
      Person.top_posters(@report_date, 1).should == []
    end

  end

  describe '.all_before' do
    it "returns all people who posted before the given date" do
      photo = Photo.make :dateadded => Time.utc(2011)
      Person.all_before(Time.utc(2011)).should == [ photo.person ]
    end

    it "returns all people who guessed before the given date" do
      guess = Guess.make :added_at => Time.utc(2011)
      Person.all_before(Time.utc(2011)).should == [ guess.person ]
    end

    it "ignores people who did neither" do
      Person.make
      Person.all_before(Time.utc(2011)).should == []
    end

    it "ignores people who only posted after the given date" do
      Photo.make :dateadded => Time.utc(2012)
      Person.all_before(Time.utc(2011)).should == []
    end

    it "returns all people who only guessed after the given date" do
      Guess.make :added_at => Time.utc(2012)
      Person.all_before(Time.utc(2011)).should == []
    end

  end

  describe '.by_score' do
    it "groups people by score" do
      person1 = Person.make 1
      person2 = Person.make 2
      Person.by_score([ person1, person2 ], Time.utc(2011)).should == { 0 => [ person1, person2 ] }
    end

    it "adds up guesses" do
      person = Person.make
      Guess.make 1, :person => person, :added_at => Time.utc(2011)
      Guess.make 2, :person => person, :added_at => Time.utc(2011)
      Person.by_score([ person ], Time.utc(2011)).should == { 2 => [ person ] }
    end

    it "ignores guesses from after the report date" do
      guess = Guess.make :added_at => Time.utc(2012)
      Person.by_score([ guess.person ], Time.utc(2011)).should == { 0 => [ guess.person ] }
    end

  end

  describe '.add_change_in_standings' do
    before do
      @person = Person.make 1
      @person[:posts] = 1
      @person[:previous_posts] = 1
      @people = [ @person ]
    end

    it "congratulates a new guesser" do
      @person[:previous_posts] = 0
      adds_change(
        { 1 => [ @person ] },
        { 0 => [ @person ] },
        'scored his or her first point. Congratulations, and welcome to GWSF!')
    end

    it "mentions a new guesser's points after the first" do
      adds_change(
        { 2 => [ @person ] },
        { 0 => [ @person ] },
        'scored his or her first point (and 1 more). Congratulations!')
    end

    it "mentions climbing" do
      other = Person.make 2
      @people << other
      adds_change(
        { 3 => [ @person ], 2 => [ other ] },
        { 2 => [ other ], 1 => [ @person ] },
        'climbed from 2nd to 1st place, passing 2_username')
    end

    it "says jumped if the guesser climbed more than one place" do
      other2 = Person.make 2
      other3 = Person.make 3
      @people += [ other2, other3 ]
      adds_change(
        { 4 => [ @person ], 3 => [ other2 ], 2 => [ other3 ] },
        { 3 => [ other2 ], 2 => [ other3 ], 1 => [ @person ] },
        'jumped from 3rd to 1st place, passing 2 other players')
    end

    it "indicates a new tie" do
      other2 = Person.make 2
      @people << other2
      adds_change(
        { 2 => [ other2, @person ] },
        { 2 => [ other2 ], 1 => [ @person ] },
        'climbed from 2nd to 1st place, tying 2_username')
    end

    it "doesn't name names if the guesser is tied with more than one other person" do
      other2 = Person.make 2
      other3 = Person.make 3
      @people += [ other2, other3 ]
      adds_change(
        { 2 => [ other2, other3, @person ] },
        { 2 => [ other2, other3 ], 1 => [ @person ] },
        'jumped from 3rd to 1st place, tying 2 other players')
    end

    it "handles passing and tying at the same time" do
      other2 = Person.make 2
      other3 = Person.make 3
      @people += [ other2, other3 ]
      adds_change(
        { 3 => [ @person, other2 ], 2 => [ other3 ] },
        { 3 => [ other2 ], 2 => [ other3 ], 1 => [ @person ] },
        'jumped from 3rd to 1st place, passing 3_username and tying 2_username')
    end

    [ 222, 500, 3300 ].each do |club|
      it "welcomes the guesser to the #{club} club" do
        adds_change(
          { club => [ @person ] },
          { club - 1 => [ @person ] },
          "Welcome to the #{club} club!")
      end
    end

    it "notes numeric milestones" do
      adds_change(
        { 100 => [ @person ] },
        { 99 => [ @person ] },
        'Congratulations on reaching 100 points!')
    end

    it "says passing instead of reaching when appropriate" do
      adds_change(
        { 101 => [ @person ] },
        { 99 => [ @person ] },
        'Congratulations on passing 100 points!')
    end

    it "reports club, not milestone, if both are options" do
      adds_change(
        { 222 => [ @person ] },
        { 199 => [ @person ] },
        'Welcome to the 222 club!')
    end

    it "welcomes the guesser to the top ten" do
      others = (2 .. 11).map { |n| Person.make n }
      @people += others
      others_by_score = {}
      others.each_with_index { |other, i| others_by_score[i + 2] = [ other ] }
      adds_change(
        others_by_score.merge({ 12 => [ @person ] }),
        others_by_score.merge({ 1 => [ @person ] }),
        'jumped from 11th to 1st place. Welcome to the top ten!')
    end

    it "congratulates and welcomes to the top ten at the same time" do
      others = (2 .. 11).map { |n| Person.make n }
      @people += others
      others_by_score = {}
      others.each_with_index { |other, i| others_by_score[i + 2] = [ other ] }
      adds_change(
        others_by_score.merge({ 100 => [ @person ] }),
        others_by_score.merge({ 1 => [ @person ] }),
        'jumped from 11th to 1st place. Congratulations on reaching 100 points! Welcome to the top ten!')
    end

    def adds_change(people_by_score, people_by_previous_score, expected_change)
      previous_report_date = Time.utc(2010)
      stub(Person).by_score(@people, previous_report_date) { people_by_previous_score }
      stub(Photo).add_posts @people, previous_report_date, :previous_posts
      guessers = [ [ @person, [] ] ]
      Person.add_change_in_standings people_by_score, @people, previous_report_date, guessers
      @person[:change_in_standing].should == expected_change
    end

  end

  describe '.add_score_and_place' do
    it "adds their place to each person" do
      person = Person.make
      people_by_score = { 0 => [ person ] }
      Person.add_score_and_place people_by_score, :score, :place
      person[:score].should == 0
      person[:place].should == 1
    end

    it "gives a lower (numerically greater) place to people with lower scores" do
      first = Person.make 1
      second = Person.make 2
      people_by_score = { 1 => [ first ], 0 => [ second ] }
      Person.add_score_and_place people_by_score, :score, :place
      first[:place].should == 1
      second[:place].should == 2
    end

    it "handles ties" do
      tied1 = Person.make 1
      tied2 = Person.make 2
      people_by_score = { 0 => [ tied1, tied2 ] }
      Person.add_score_and_place people_by_score, :score, :place
      tied1[:place].should == 1
      tied2[:place].should == 1
    end

    it "counts the number of people above one, not the number of scores above one" do
      tied1 = Person.make 1
      tied2 = Person.make 2
      third = Person.make 3
      people_by_score = { 1 => [ tied1, tied2 ], 0 => [ third ] }
      Person.add_score_and_place people_by_score, :score, :place
      third[:place].should == 3
    end

  end

  describe '.most_points_in_2010' do
    it 'returns a list of scorers with their scores' do
      guess = Guess.make :guessed_at => Time.utc(2010)
      top_scorers = Person.most_points_in_2010
      top_scorers.should == [ guess.person ]
      top_scorers[0][:points].should == 1
    end

    it 'ignores guesses made before 2010' do
      Guess.make :guessed_at => Time.utc(2009)
      Person.most_points_in_2010.should == []
    end

    it 'ignores guesses made after 2010' do
      Guess.make :guessed_at => Time.utc(2011)
      Person.most_points_in_2010.should == []
    end

    it 'returns only the top 10 scorers' do
      10.times do |i|
        guess = Guess.make i.to_s + '_first_point', :guessed_at => Time.utc(2010)
        Guess.make i.to_s + '_second_point', :person => guess.person, :guessed_at => Time.utc(2010)
      end
      single_guess = Guess.make :guessed_at => Time.utc(2010)
      top_scorers = Person.most_points_in_2010
      top_scorers.size.should == 10
      #noinspection RubyResolve
      top_scorers.should_not include(single_guess.person)
    end

  end

  describe '.most_posts_in_2010' do
    it 'returns a lists of posters with their number of posts' do
      post = Photo.make :dateadded => Time.utc(2010)
      top_posters = Person.most_posts_in_2010
      top_posters.should == [ post.person ]
      top_posters[0][:posts].should == 1
    end

    it 'ignores posts before 2010' do
      Photo.make :dateadded => Time.utc(2009)
      Person.most_posts_in_2010.should == []
    end

    it 'ignores posts after 2010' do
      Photo.make :dateadded => Time.utc(2011)
      Person.most_posts_in_2010.should == []
    end

    it 'returns only the top 10 posters' do
      10.times do |i|
        post = Photo.make i.to_s + '_first_post', :dateadded => Time.utc(2010)
        Photo.make i.to_s + '_second_post', :person => post.person, :dateadded => Time.utc(2010)
      end
      single_post = Photo.make :dateadded => Time.utc(2010)
      top_posters = Person.most_posts_in_2010
      top_posters.size.should == 10
      #noinspection RubyResolve
      top_posters.should_not include(single_post.person)
    end

  end

  describe '.rookies_with_most_points_in_2010' do
    it 'returns a list of rookies with their score' do
      guess = Guess.make :guessed_at => Time.utc(2010)
      top_scorers = Person.rookies_with_most_points_in_2010
      top_scorers.should == [ guess.person ]
      top_scorers[0][:points].should == 1
    end

    it 'ignores people who guessed before 2010' do
      Guess.make :guessed_at => Time.utc(2009)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'ignores people who guessed for the first time in 2010 but posted for the first time before 2010' do
      guess = Guess.make :guessed_at => Time.utc(2010)
      Photo.make 'before', :person => guess.person, :dateadded => Time.utc(2009)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'ignores guesses made after 2010' do
      Guess.make :guessed_at => Time.utc(2011)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'ignores people who posted for the first time in 2010 but guessed for the first time after 2010' do
      post = Photo.make :dateadded => Time.utc(2010)
      Guess.make 'after', :person => post.person, :guessed_at => Time.utc(2011)
      Person.rookies_with_most_points_in_2010.should == []
    end

    it 'returns only the top 10 rookie scorers' do
      10.times do |i|
        guess = Guess.make i.to_s + '_first_point', :guessed_at => Time.utc(2010)
        Guess.make i.to_s + '_second_point', :person => guess.person, :guessed_at => Time.utc(2010)
      end
      single_guess = Guess.make :guessed_at => Time.utc(2010)
      top_scorers = Person.rookies_with_most_points_in_2010
      top_scorers.size.should == 10
      #noinspection RubyResolve
      top_scorers.should_not include(single_guess.person)
    end

  end

  describe '.rookies_with_most_posts_in_2010' do
    it 'returns a list of rookies with their number of posts' do
      post = Photo.make :dateadded => Time.utc(2010)
      top_posters = Person.rookies_with_most_posts_in_2010
      top_posters.should == [ post.person ]
      top_posters[0][:posts].should == 1
    end

    it 'ignores people who posted before 2010' do
      Photo.make :dateadded => Time.utc(2009)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'ignores people who posted for the first time in 2010 but guessed for the first time before 2010' do
      post = Photo.make :dateadded => Time.utc(2010)
      Guess.make 'before', :person => post.person, :guessed_at => Time.utc(2009)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'ignores posts made after 2010' do
      Photo.make :dateadded => Time.utc(2011)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'ignores people who guessed for the first time in 2010 but posted for the first time after 2010' do
      guess = Guess.make :guessed_at => Time.utc(2010)
      Photo.make 'after', :person => guess.person, :dateadded => Time.utc(2011)
      Person.rookies_with_most_posts_in_2010.should == []
    end

    it 'returns only the top 10 rookie posters' do
      10.times do |i|
        post = Photo.make i.to_s + '_first_post', :dateadded => Time.utc(2010)
        Photo.make i.to_s + '_second_post', :person => post.person, :dateadded => Time.utc(2010)
      end
      single_post = Photo.make :dateadded => Time.utc(2010)
      top_posters = Person.rookies_with_most_posts_in_2010
      top_posters.size.should == 10
      #noinspection RubyResolve
      top_posters.should_not include(single_post.person)
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

    it "ignores a poster which this person has guessed less than #{Person::MIN_GUESSES_FOR_FAVORITE} times" do
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

    it "ignores a guesser who has guessed this person less than #{Person::MIN_GUESSES_FOR_FAVORITE} times" do
      #noinspection RubyUnusedLocalVariable
      devoted_guesser, poster = make_potential_favorite_poster(9, 15)
      poster.favorite_posters_of.should == []
    end
    
  end

  describe '#destroy_if_has_no_dependents' do
    it 'destroys the person' do
      person = Person.make
      person.destroy_if_has_no_dependents
      Person.count.should == 0
    end

    it 'but not if they have a photo' do
      person = Person.make
      Photo.make :person => person
      person.destroy_if_has_no_dependents
      Person.all.should == [ person ]
    end

    it 'but not if they have a guess' do
      person = Person.make
      Guess.make :person => person
      person.destroy_if_has_no_dependents
      Person.find(person.id).should == person
    end

  end

  # Utilities

  def make_potential_favorite_poster(posts_by_favorite, posts_by_others)
    favorite_poster = Person.make 'favorite_poster'
    devoted_guesser = Person.make 'devoted_guesser'
    (1 .. posts_by_favorite).each do |n|
      photo = Photo.make n, :person => favorite_poster
      Guess.make n, :person => devoted_guesser, :photo => photo
    end
    other_poster = Person.make 'other_poster'
    ((posts_by_favorite + 1) .. (posts_by_favorite + posts_by_others)).each do |n|
      Photo.make n, :person => other_poster
    end
    return devoted_guesser, favorite_poster
  end

end
