describe StatisticsPerson do
  describe '.update_statistics' do
    it "initializes statistics to nil or 0" do
      person = create :statistics_person, comments_to_guess: 1, comments_per_post: 1, comments_to_be_guessed: 1
      StatisticsPerson.update_statistics
      person.reload
      expect(person.comments_to_guess).to be_nil
      expect(person.comments_per_post).to eq(0)
      expect(person.comments_to_be_guessed).to be_nil
    end

    describe 'when updating comments_to_guess' do
      # Run commented_at through the database to avoid failures due to different treatment of fractional seconds
      let(:guess) { (create :guess, commented_at: 10.seconds.ago).tap &:reload }

      before do
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username, commented_at: guess.commented_at
      end

      it "sets the attribute to average # of comments/guess" do
        guesser_attribute_is_1
      end

      it "ignores comments made after the guess" do
        create :comment, photo: guess.photo, flickrid: guess.person.flickrid, username: guess.person.username
        guesser_attribute_is_1
      end

      it "ignores comments made by someone other than the guesser" do
        create :comment, photo: guess.photo, commented_at: 11.seconds.ago
        guesser_attribute_is_1
      end

      def guesser_attribute_is_1
        StatisticsPerson.update_statistics
        guess.person.reload
        expect(guess.person.comments_to_guess).to eq(1)
      end

    end

    describe 'when updating comments_per_post' do
      it "sets the attribute to average # of comments on their post" do
        comment = create :comment
        StatisticsPerson.update_statistics
        comment.photo.person.reload
        expect(comment.photo.person.comments_per_post).to eq(1)
      end

      it "ignores comments made by the poster" do
        photo = create :photo
        create :comment, photo: photo, flickrid: photo.person.flickrid, username: photo.person.username
        StatisticsPerson.update_statistics
        photo.person.reload
        expect(photo.person.comments_per_post).to eq(0)
      end

    end

    describe 'when updating comments_to_be_guessed' do
      # Run commented_at through the database to avoid failures due to different treatment of fractional seconds
      let(:guess) { (create :guess, commented_at: 10.seconds.ago).tap &:reload }

      before do
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username, commented_at: guess.commented_at
      end

      it "sets the attribute to average # of comments for their photos to be guessed" do
        poster_attribute_is_1
      end

      it "ignores comments made after the guess" do
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username
        poster_attribute_is_1
      end

      it "ignores comments made by the poster" do
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username, commented_at: 11.seconds.ago
        poster_attribute_is_1
      end

      def poster_attribute_is_1
        StatisticsPerson.update_statistics
        guess.photo.person.reload
        expect(guess.photo.person.comments_to_be_guessed).to eq(1)
      end

    end

  end

end
