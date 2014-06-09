describe Person do

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }

    it 'should handle non-ASCII characters' do
      non_ascii_username = '猫娘/ nekomusume'
      create :person, username: non_ascii_username
      Person.all[0].username.should == non_ascii_username
    end

  end

  describe '.find_by_multiple_fields' do
    let(:person) { create :person }

    it 'finds a person by username' do
      Person.find_by_multiple_fields(person.username).should == person
    end

    it 'finds a person by flickrid' do
      Person.find_by_multiple_fields(person.flickrid).should == person
    end

    it 'finds a person by GWW ID' do
      Person.find_by_multiple_fields(person.id.to_s).should == person
    end

    it 'punts back to the home page' do
      Person.find_by_multiple_fields('xxx').should be_nil
    end

  end

  describe '.nemeses' do
    it "lists guessers and their favorite posters" do
      guesser, favorite_poster = make_potential_favorite_poster(10, 15)
      nemeses = Person.nemeses
      nemeses.should == [ guesser ]
      nemesis = nemeses[0]
      nemesis.poster.should == favorite_poster
      nemesis.bias.should == 2.5
    end

    it "ignores less than #{Person::MIN_GUESSES_FOR_FAVORITE} guesses" do
      make_potential_favorite_poster(9, 15)
      Person.nemeses.should == []
    end

  end

  describe '.top_guessers' do
    let(:report_time) { Time.local 2011, 1, 3 }
    let(:report_day) { report_time.beginning_of_day }

    it 'returns a structure of scores by day, week, month and year' do
      expected = expected_periods_for_one_guess_at_report_time
      guess = create :guess, commented_at: report_time
      (0 .. 3).each { |division| expected[division][0].scores[1] = [ guess.person ] }
      Person.top_guessers(report_time).should == expected
    end

    it 'handles multiple guesses in the same period' do
      expected = expected_periods_for_one_guess_at_report_time
      guesser = create :person
      create :guess, person: guesser, commented_at: report_time
      create :guess, person: guesser, commented_at: report_time + 1.minute
      (0 .. 3).each { |division| expected[division][0].scores[2] = [ guesser ] }
      Person.top_guessers(report_time).should == expected
    end

    it 'handles multiple guessers with the same scores in the same periods' do
      expected = expected_periods_for_one_guess_at_report_time
      guess1 = create :guess, commented_at: report_time
      guess2 = create :guess, commented_at: report_time
      (0 .. 3).each { |division| expected[division][0].scores[1] = [ guess1.person, guess2.person ] }
      Person.top_guessers(report_time).should == expected
    end

    def expected_periods_for_one_guess_at_report_time
      [
        (0 .. 6).map { |i| Period.starting_at report_day - i.days, 1.day },
        [ Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day) ] +
          (0 .. 4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [ Period.new(report_day.beginning_of_month, report_day + 1.day) ] +
          (0 .. 11).map { |i| Period.starting_at report_day.beginning_of_month - (i + 1).months, 1.month },
        [ Period.new(report_day.beginning_of_year, report_day + 1.day) ]
      ]
    end

    it 'handles previous years' do
      expected = [
        (0 .. 6).map { |i| Period.starting_at report_day - i.days, 1.day },
        [ Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day) ] +
          (0 .. 4).map { |i| Period.starting_at report_day.beginning_of_week - 1.day - (i + 1).weeks, 1.week },
        [ Period.new(report_day.beginning_of_month, report_day + 1.day) ] +
          (0 .. 11).map { |i| Period.starting_at report_day.beginning_of_month - (i + 1).months, 1.month },
        [ Period.new(report_day.beginning_of_year, report_day + 1.day),
          Period.starting_at(report_day.beginning_of_year - 1.year, 1.year) ]
      ]
      guess = create :guess, commented_at: Time.local(2010, 1, 1).getutc
      expected[2][12].scores[1] = [ guess.person ]
      expected[3][1].scores[1] = [ guess.person ]
      Person.top_guessers(report_time).should == expected
    end

  end

  describe '.update_statistics' do
    it 'initializes statistics to nil or 0' do
      person = create :person, comments_to_guess: 1, comments_per_post: 1, comments_to_be_guessed: 1
      Person.update_statistics
      person.reload
      person.comments_to_guess.should == nil
      person.comments_per_post.should == 0
      person.comments_to_be_guessed.should == nil
    end

    describe 'when updating comments_to_guess' do
      let(:commented_at) { 10.seconds.ago }
      let(:guess) { create :guess, commented_at: commented_at }

      before do
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username, commented_at: commented_at
      end

      it 'sets the attribute to average # of comments/guess' do
        guesser_attribute_is_1
      end

      it 'ignores comments made after the guess' do
        create :comment, photo: guess.photo, flickrid: guess.person.flickrid, username: guess.person.username
        guesser_attribute_is_1
      end

      it 'ignores comments made by someone other than the guesser' do
        create :comment, photo: guess.photo, commented_at: 11.seconds.ago
        guesser_attribute_is_1
      end

      def guesser_attribute_is_1
        Person.update_statistics
        guess.person.reload
        guess.person.comments_to_guess.should == 1
      end

    end

    describe 'when updating comments_per_post' do
      it 'sets the attribute to average # of comments on their post' do
        comment = create :comment
        Person.update_statistics
        comment.photo.person.reload
        comment.photo.person.comments_per_post.should == 1
      end

      it 'ignores comments made by the poster' do
        photo = create :photo
        create :comment, photo: photo, flickrid: photo.person.flickrid, username: photo.person.username
        Person.update_statistics
        photo.person.reload
        photo.person.comments_per_post.should == 0
      end

    end

    describe 'when updating comments_to_be_guessed' do
      let(:commented_at) { 10.seconds.ago }
      let(:guess) { create :guess, commented_at: commented_at }

      before do
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username, commented_at: commented_at
      end

      it 'sets the attribute to average # of comments for their photos to be guessed' do
        poster_attribute_is_1
      end

      it 'ignores comments made after the guess' do
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username
        poster_attribute_is_1
      end

      it 'ignores comments made by the poster' do
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username, commented_at: 11.seconds.ago
        poster_attribute_is_1
      end

      def poster_attribute_is_1
        Person.update_statistics
        guess.photo.person.reload
        guess.photo.person.comments_to_be_guessed.should == 1
      end

    end

  end

  describe '#destroy_if_has_no_dependents' do
    let(:person) { create :person }

    it 'destroys the person' do
      person.destroy_if_has_no_dependents
      Person.count.should == 0
    end

    it 'but not if they have a photo' do
      create :photo, person: person
      person.destroy_if_has_no_dependents
      Person.all.should == [ person ]
    end

    it 'but not if they have a guess' do
      create :guess, person: person
      person.destroy_if_has_no_dependents
      Person.find(person.id).should == person
    end

  end

end
