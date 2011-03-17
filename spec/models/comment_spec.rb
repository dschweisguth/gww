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
        photo.reload
        photo.game_status.should == 'revealed'
        revelation = Revelation.find_by_photo_id comment.photo.id
        revelation.revelation_text.should == comment.comment_text
        revelation.revealed_at.should == comment.commented_at
      end

      it 'updates an existing revelation' do
        old_revelation = Revelation.make
        comment = Comment.make :photo => old_revelation.photo,
          :flickrid => old_revelation.photo.person.flickrid,
          :username => old_revelation.photo.person.username,
          :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, ''
        new_revelations = Revelation.find_all_by_photo_id comment.photo
        new_revelations.should == [ old_revelation ]
        new_revelation = new_revelations[0]
        # Note that the following two values are different than those for old_guess
        new_revelation.revelation_text.should == comment.comment_text
        new_revelation.revealed_at.should == comment.commented_at
      end

      it 'handles a redundant username' do
        photo = Photo.make
        comment = Comment.make :photo => photo, :flickrid => photo.person.flickrid,
          :username => photo.person.username, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, photo.person.username
        photo.reload
        photo.game_status.should == 'revealed'
        revelation = Revelation.find_by_photo_id comment.photo.id
        revelation.revelation_text.should == comment.comment_text
        revelation.revealed_at.should == comment.commented_at
      end

      it "gets text from another user's comment" do
        photo = Photo.make
        # The person must have made a comment to be identified by username. TODO Dave just try getting them from the people table first
        Comment.make :flickrid => photo.person.flickrid, :username => photo.person.username
        comment = Comment.make :photo => photo, :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, photo.person.username
        photo.reload
        photo.game_status.should == 'revealed'
        revelation = Revelation.find_by_photo_id comment.photo.id
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
        guess = Guess.find_by_photo_id comment.photo
        guess.person_id.should == guesser.id
        guess.guess_text.should == comment.comment_text
        guess.guessed_at.should == comment.commented_at
        guess.photo.reload
        guess.photo.game_status.should == 'found'
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
        guess = Guess.find_by_photo_id comment.photo
        guess.person_id.should == guesser.id
        guess.guess_text.should == comment.comment_text
        guess.guessed_at.should == comment.commented_at
        guess.photo.reload
        guess.photo.game_status.should == 'found'
      end

      it 'gives the point to another user' do
        scorer = Person.make 'scorer'
        scorer_comment = Comment.make 'scorer',
          :flickrid => scorer.flickrid, :username => scorer.username
        answer_comment = Comment.make 'answer', :commented_at => Time.utc(2011)
        Comment.add_answer answer_comment.id, scorer_comment.username
        guess = Guess.find_by_photo_id answer_comment.photo, :include => :person
        guess.person.flickrid.should == scorer_comment.flickrid
        guess.person.username.should == scorer_comment.username
        guess.guess_text.should == answer_comment.comment_text
        guess.guessed_at.should == answer_comment.commented_at
        answer_comment.photo.reload
        answer_comment.photo.game_status.should == 'found'
      end

      it 'updates an existing guess' do
        old_guess = Guess.make
        comment = Comment.make :photo => old_guess.photo,
          :flickrid => old_guess.person.flickrid, :username => old_guess.person.username,
          :commented_at => Time.utc(2011)
        Comment.add_answer comment.id, ''
        new_guesses = Guess.find_all_by_photo_id comment.photo
        new_guesses.should == [ old_guess ]
        new_guess = new_guesses[0]
        # Note that the following two values are different than those for old_guess
        new_guess.guess_text.should == comment.comment_text
        new_guess.guessed_at.should == comment.commented_at
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

end
