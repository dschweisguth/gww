describe PersonIndexSupport do
  describe '.all_sorted' do
    before do
      stub(Photo).group(:person_id).stub!.count { {} }
      stub(Guess).group(:person_id).stub!.count { {} }
      stub(Person).guesses_per_day { {} }
      stub(Person).posts_per_day { {} }
      stub(Person).guess_speeds { {} }
      stub(Person).be_guessed_speeds { {} }
      stub(Person).views_per_post { {} }
      stub(Person).faves_per_post { {} }
    end

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
      @person1.update! comments_to_guess: 1
      @person2.update! comments_to_guess: 2
      stub_score 2, 1
      puts_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-guess, score' do
      create_people_named 'a', 'z'
      @person1.update! comments_to_guess: 1
      @person2.update! comments_to_guess: 1
      stub_score 1, 2
      puts_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-to-guess, score, username' do
      create_people_named 'z', 'a'
      @person1.update! comments_to_guess: 1
      @person2.update! comments_to_guess: 1
      stub_score 1, 1
      puts_person2_before_person1 'comments-to-guess'
    end

    it 'sorts by comments-per-post' do
      create_people_named 'a', 'z'
      @person1.update! comments_per_post: 1
      @person2.update! comments_per_post: 2
      stub_post_count 2, 1
      puts_person2_before_person1 'comments-per-post'
    end

    it 'sorts by comments-per-post, post count' do
      create_people_named 'a', 'z'
      @person1.update! comments_per_post: 1
      @person2.update! comments_per_post: 1
      stub_post_count 1, 2
      puts_person2_before_person1 'comments-per-post'
    end

    it 'sorts by comments-per-post, post count, username' do
      create_people_named 'z', 'a'
      @person1.update! comments_per_post: 1
      @person2.update! comments_per_post: 1
      stub_post_count 1, 1
      puts_person2_before_person1 'comments-per-post'
    end

    it 'sorts by comments-to-be-guessed' do
      create_people_named 'a', 'z'
      @person1.update! comments_to_be_guessed: 1
      @person2.update! comments_to_be_guessed: 2
      stub_post_count 2, 1
      puts_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by comments-to-be-guessed, post count' do
      create_people_named 'a', 'z'
      @person1.update! comments_to_be_guessed: 1
      @person2.update! comments_to_be_guessed: 1
      stub_post_count 1, 2
      puts_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by comments-to-be-guessed, post count, username' do
      create_people_named 'z', 'a'
      @person1.update! comments_to_be_guessed: 1
      @person2.update! comments_to_be_guessed: 1
      stub_post_count 1, 1
      puts_person2_before_person1 'comments-to-be-guessed'
    end

    it 'sorts by views-per-post' do
      create_people_named 'a', 'z'
      stub(Person).views_per_post { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      puts_person2_before_person1 'views-per-post'
    end

    it 'sorts by views-per-post, post count' do
      create_people_named 'a', 'z'
      stub(Person).views_per_post { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      puts_person2_before_person1 'views-per-post'
    end

    it 'sorts by views-per-post, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).views_per_post { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      puts_person2_before_person1 'views-per-post'
    end

    it 'sorts by faves-per-post' do
      create_people_named 'a', 'z'
      stub(Person).faves_per_post { { @person1.id => 1, @person2.id => 2 } }
      stub_post_count 2, 1
      puts_person2_before_person1 'faves-per-post'
    end

    it 'sorts by faves-per-post, post count' do
      create_people_named 'a', 'z'
      stub(Person).faves_per_post { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 2
      puts_person2_before_person1 'faves-per-post'
    end

    it 'sorts by faves-per-post, post count, username' do
      create_people_named 'z', 'a'
      stub(Person).faves_per_post { { @person1.id => 1, @person2.id => 1 } }
      stub_post_count 1, 1
      puts_person2_before_person1 'faves-per-post'
    end

    it 'sorts the other direction, too' do
      create_people_named 'a', 'z'
      Person.all_sorted('username', '-').should == [ @person2, @person1 ]
    end

    def create_people_named(username1, username2)
      @person1 = create :person, username: username1
      @person2 = create :person, username: username2
    end

    def stub_post_count(count1, count2)
      # noinspection RubyArgCount
      stub(Photo).group(:person_id).stub!.count { { @person1.id => count1, @person2.id => count2 } }
    end

    def stub_score(count1, count2)
      # noinspection RubyArgCount
      stub(Guess).group(:person_id).stub!.count { { @person1.id => count1, @person2.id => count2 } }
    end

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

  describe '.guesses_per_day' do
    it 'returns a map of person ID to average guesses per day' do
      guess = create :guess, commented_at: 4.days.ago
      Person.guesses_per_day.should == { guess.person.id => 0.25 }
    end
  end

  describe '.posts_per_day' do
    it 'returns a map of person ID to average posts per day' do
      photo = create :photo, dateadded: 4.days.ago
      Person.posts_per_day.should == { photo.person.id => 0.25 }
    end
  end

  describe '.guess_speeds' do
    it 'returns a map of person ID to average seconds to guess' do
      now = Time.now
      photo = create :photo, dateadded: now - 5
      guess = create :guess, photo: photo, commented_at: now - 1
      Person.guess_speeds.should == { guess.person.id => 4 }
    end
  end

  describe '.be_guessed_speeds' do
    it 'returns a map of person ID to average seconds for their photos to be guessed' do
      now = Time.now
      photo = create :photo, dateadded: now - 5
      create :guess, photo: photo, commented_at: now - 1
      Person.be_guessed_speeds.should == { photo.person.id => 4 }
    end
  end

  describe '.views_per_post' do
    it 'returns a map of person ID to average # of views per post' do
      photo = create :photo, views: 1
      Person.views_per_post.should == { photo.person.id => 1 }
    end
  end

  describe '.faves_per_post' do
    it 'returns a map of person ID to average # of faves per post' do
      photo = create :photo, faves: 1
      Person.faves_per_post.should == { photo.person.id => 1 }
    end
  end

end
