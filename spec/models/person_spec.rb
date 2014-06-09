require 'spec_helper'

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

  describe '.standing' do
    let(:person) { create :person }

    it "returns the person's score position" do
      Person.standing(person).should == [ 1, false ]
    end

    it "considers other players' scores" do
      create :guess
      Person.standing(person).should == [ 2, false ]
    end

    it "detects ties" do
      guess1 = create :guess, person: person
      create :guess
      Person.standing(person).should == [ 1, true ]
    end

  end

  describe '.posts_standing' do
    let(:person) { create :person }

    it "returns the person's post position" do
      Person.posts_standing(person).should == [ 1, false ]
    end

    it "considers other players' posts" do
      create :photo
      Person.posts_standing(person).should == [ 2, false ]
    end

    it "detects ties" do
      post1 = create :photo, person: person
      create :photo
      Person.posts_standing(person).should == [ 1, true ]
    end

  end

  describe '#favorite_posters' do
    it "lists the posters which this person has guessed #{Person::MIN_BIAS_FOR_FAVORITE} or more times as often as this person has guessed all posts" do
      guesser, favorite_poster = make_potential_favorite_poster(10, 15)
      favorite_posters = guesser.favorite_posters
      favorite_posters.should == [ favorite_poster ]
      favorite_posters[0].bias.should == Person::MIN_BIAS_FOR_FAVORITE
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
      favorite_posters_of[0].bias.should == Person::MIN_BIAS_FOR_FAVORITE
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

  describe '#paginated_commented_photos' do
    let(:person) { create :person }

    it "returns the photos commented on by a given user" do
      comment = create :comment, flickrid: person.flickrid, username: person.username
      person.paginated_commented_photos(1).should == [comment.photo]
    end

    it "ignores photos commented on by another user" do
      create :comment
      person.paginated_commented_photos(1).should == []
    end

    it "paginates" do
      3.times { create :comment, flickrid: person.flickrid, username: person.username }
      person.paginated_commented_photos(1, 2).length.should == 2
    end

    it "returns each photo only once, even if the person commented on it more than once" do
      photo = create :photo
      create :comment, photo: photo, flickrid: person.flickrid, username: person.username
      create :comment, photo: photo, flickrid: person.flickrid, username: person.username
      person.paginated_commented_photos(1).should == [photo]
    end

    it "sorts the most recently updated photos first" do
      photo1 = create :photo, lastupdate: 2.days.ago
      create :comment, photo: photo1, flickrid: person.flickrid, username: person.username
      photo2 = create :photo, lastupdate: 1.days.ago
      create :comment, photo: photo2, flickrid: person.flickrid, username: person.username
      person.paginated_commented_photos(1).should == [photo2, photo1]
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

  # Utilities

  def make_potential_favorite_poster(posts_by_favorite, posts_by_others)
    favorite_poster = create :person
    devoted_guesser = create :person
    (1 .. posts_by_favorite).each do |n|
      photo = create :photo, person: favorite_poster
      create :guess, person: devoted_guesser, photo: photo
    end
    other_poster = create :person
    ((posts_by_favorite + 1) .. (posts_by_favorite + posts_by_others)).each do |n|
      create :photo, person: other_poster
    end
    return devoted_guesser, favorite_poster
  end

end
