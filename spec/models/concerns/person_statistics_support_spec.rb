describe PersonStatisticsSupport do
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

end
