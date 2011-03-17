require 'spec_helper'

describe Comment do
  describe '#photo' do
    it { should belong_to :photo }
  end

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }
    it { should have_readonly_attribute :username }

    it 'should handle non-ASCII characters' do
      non_ascii_username = '猫娘/ nekomusume'
      Comment.make :username => non_ascii_username
      Comment.all[0].username.should == non_ascii_username
    end

  end

  describe '#comment_text' do
    it { should validate_presence_of :comment_text }
    it { should have_readonly_attribute :comment_text }

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      Comment.make :comment_text => non_ascii_text
      Comment.all[0].comment_text.should == non_ascii_text
    end

  end

  describe '#commented_at' do
    it { should validate_presence_of :commented_at }
    it { should have_readonly_attribute :commented_at }
  end

  describe '.add_answer' do
    describe 'when adding a revelation' do
      it 'adds a revelation' do
        photo = Photo.make
        comment = Comment.make :photo => photo, :flickrid => photo.person.flickrid,
          :username => photo.person.username, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, ''
        photo_is_revealed_and_revelation_matches comment
      end

      it 'handles a redundant username' do
        photo = Photo.make
        comment = Comment.make :photo => photo, :flickrid => photo.person.flickrid,
          :username => photo.person.username, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, photo.person.username
        photo_is_revealed_and_revelation_matches comment
      end

      it "gets text from another user's comment" do
        photo = Photo.make
        comment = Comment.make :photo => photo, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, photo.person.username
        photo_is_revealed_and_revelation_matches comment
      end

      it 'updates an existing revelation' do
        old_revelation = Revelation.make
        comment = Comment.make :photo => old_revelation.photo,
          :flickrid => old_revelation.photo.person.flickrid,
          :username => old_revelation.photo.person.username,
          :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, ''
        photo_is_revealed_and_revelation_matches comment
      end

      def photo_is_revealed_and_revelation_matches(comment)
        revelations = Revelation.find_all_by_photo_id comment.photo
        revelations.length.should == 1
        revelation = revelations[0]
        revelation.photo.game_status.should == 'revealed'
        revelation.revelation_text.should == comment.comment_text
        revelation.revealed_at.should == comment.commented_at
      end

      it 'deletes an existing guess' do
        photo = Photo.make
        comment = Comment.make :photo => photo, :flickrid => photo.person.flickrid,
          :username => photo.person.username, :commented_at => Time.utc(2011)
        guess = Guess.make :photo => photo
        Comment.add_answer comment.id, ''
        Guess.count.should == 0
        owner_does_not_exist guess
      end

    end

    describe 'when adding a guess' do
      it 'adds a guess' do
        guesser = Person.make
        comment = Comment.make :flickrid => guesser.flickrid,
          :username => guesser.username, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, ''
        guess_matches_and_person_is comment, guesser
      end

      it 'creates the guesser if necessary' do
        comment = Comment.make
        Comment.add_answer comment.id, ''
        guess = Guess.find_by_photo_id comment.photo, :include => :person
        guess.person.flickrid.should == comment.flickrid
        guess.person.username.should == comment.username
      end

      it 'handles a redundant username' do
        guesser = Person.make
        comment = Comment.make :flickrid => guesser.flickrid,
          :username => guesser.username, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, guesser.username
        guess_matches_and_person_is comment, guesser
      end

      it 'gives the point to another, new user' do
        scorer_comment = Comment.make 'scorer',
          :flickrid => 'scorer_flickrid', :username => 'scorer_person_username'
        answer_comment = Comment.make 'answer', :commented_at => Time.utc(2011)
        Comment.add_answer answer_comment.id, scorer_comment.username
        guesses = Guess.find_all_by_photo_id answer_comment.photo
        guesses.length.should == 1
        guess = guesses[0]
        guess.person.flickrid.should == scorer_comment.flickrid
        guess.person.username.should == scorer_comment.username
        guess.guess_text.should == answer_comment.comment_text
        guess.guessed_at.should == answer_comment.commented_at
        guess.photo.game_status.should == 'found'
      end

      it 'gives the point to another, known user' do
        scorer = Person.make 'scorer'
        scorer_comment = Comment.make 'scorer',
          :flickrid => scorer.flickrid, :username => scorer.username
        answer_comment = Comment.make 'answer', :commented_at => Time.utc(2011)
        Comment.add_answer answer_comment.id, scorer_comment.username
        guess_matches_and_person_is answer_comment, scorer
      end

      it 'updates an existing guess' do
        old_guess = Guess.make
        comment = Comment.make :photo => old_guess.photo,
          :flickrid => old_guess.person.flickrid, :username => old_guess.person.username,
          :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, ''
        guess_matches_and_person_is comment, old_guess.person
      end

      def guess_matches_and_person_is(comment, person)
        guesses = Guess.find_all_by_photo_id comment.photo
        guesses.length.should == 1
        guess = guesses[0]
        guess.person.should == person
        guess.guess_text.should == comment.comment_text
        guess.guessed_at.should == comment.commented_at
        guess.photo.game_status.should == 'found'
      end

      it 'deletes an existing revelation' do
        guesser = Person.make
        comment = Comment.make :flickrid => guesser.flickrid,
          :username => guesser.username, :commented_at => Time.utc(2011)
        Revelation.make :photo => comment.photo
        Comment.add_answer comment.id, ''
        Revelation.count.should == 0
      end

    end

  end

  describe '.remove_revelation' do
    it 'removes a revelation' do
      photo = Photo.make :game_status => 'revealed'
      revelation = Revelation.make :photo => photo # TODO Dave ModelFactory should handle this
      comment = Comment.make :photo => photo,
        :flickrid => photo.person.flickrid, :username => photo.person.username,
        :comment_text => revelation.revelation_text
      Comment.remove_revelation comment.id
      photo.reload
      photo.game_status.should == 'unfound'
      Revelation.count.should == 0
    end
  end

  describe '.remove_guess' do
    it 'removes a guess' do
      photo = Photo.make :game_status => 'found'
      guess = Guess.make :photo => photo
      comment = Comment.make :photo => photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :comment_text => guess.guess_text
      Comment.remove_guess comment.id
      photo.reload
      photo.game_status.should == 'unfound'
      Guess.count.should == 0
      owner_does_not_exist guess
    end

    it "leaves the photo found if there's another guess" do
      photo = Photo.make :game_status => 'found'
      guess1 = Guess.make 1, :photo => photo
      comment1 = Comment.make 1, :photo => photo,
        :flickrid => guess1.person.flickrid, :username => guess1.person.username,
        :comment_text => guess1.guess_text
      guess2 = Guess.make 2, :photo => photo
      Comment.make 2, :photo => photo,
        :flickrid => guess2.person.flickrid, :username => guess2.person.username,
        :comment_text => guess2.guess_text
      Comment.remove_guess comment1.id
      photo.reload
      photo.game_status.should == 'found'
      Guess.all.should == [ guess2 ]
    end

  end

end
