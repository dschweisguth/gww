require 'spec_helper'

describe Comment do
  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }
    it { should have_readonly_attribute :username }

    it 'should handle non-ASCII characters' do
      non_ascii_username = '猫娘/ nekomusume'
      Comment.make username: non_ascii_username
      Comment.all[0].username.should == non_ascii_username
    end

  end

  describe '#comment_text' do
    it { should validate_presence_of :comment_text }
    it { should have_readonly_attribute :comment_text }

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      Comment.make comment_text: non_ascii_text
      Comment.all[0].comment_text.should == non_ascii_text
    end

  end

  describe '#commented_at' do
    it { should validate_presence_of :commented_at }
    it { should have_readonly_attribute :commented_at }
  end

  describe '.add_selected_answer' do
    before do
      @now = Time.utc(2010)
    end

    describe 'when adding a revelation' do
      it 'adds a revelation' do
        photo = Photo.make
        comment = Comment.make photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        set_time
        Comment.add_selected_answer comment.id, ''
        photo_is_revealed_and_revelation_matches comment
      end

      it 'handles a redundant username' do
        photo = Photo.make
        comment = Comment.make photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        set_time
        Comment.add_selected_answer comment.id, photo.person.username
        photo_is_revealed_and_revelation_matches comment
      end

      it "gets text from another user's comment" do
        photo = Photo.make
        comment = Comment.make photo: photo, commented_at: Time.utc(2011)
        set_time
        Comment.add_selected_answer comment.id, photo.person.username
        photo_is_revealed_and_revelation_matches comment
      end

      it 'updates an existing revelation' do
        old_revelation = Revelation.make
        comment = Comment.make photo: old_revelation.photo,
          flickrid: old_revelation.photo.person.flickrid,
          username: old_revelation.photo.person.username,
          commented_at: Time.utc(2011)
        set_time
        Comment.add_selected_answer comment.id, ''
        photo_is_revealed_and_revelation_matches comment
      end

      def photo_is_revealed_and_revelation_matches(comment)
        revelations = Revelation.where photo: comment.photo
        revelations.length.should == 1
        revelation = revelations[0]
        revelation.photo.game_status.should == 'revealed'
        revelation.comment_text.should == comment.comment_text
        revelation.commented_at.should == comment.commented_at
        revelation.added_at.should == @now
      end

      it 'deletes an existing guess' do
        photo = Photo.make
        comment = Comment.make photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        guess = Guess.make photo: photo
        Comment.add_selected_answer comment.id, ''
        Guess.count.should == 0
        owner_does_not_exist guess
      end

      it "doesn't blow up if, when deleting an existing guess, it isn't able to delete the guesser" do
        photo = Photo.make
        comment = Comment.make photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        guess = Guess.make photo: photo
        Photo.make 2, person: guess.person
        Comment.add_selected_answer comment.id, ''
        Guess.count.should == 0
        Person.exists?(guess.person.id).should be_true
      end

    end

    describe 'when adding a guess' do
      it "adds a guess and updates the guesser if necessary" do
        guesser = Person.make
        comment = Comment.make flickrid: guesser.flickrid,
          username: guesser.username, commented_at: Time.utc(2011)
        set_time
        stub_person_request
        Comment.add_selected_answer comment.id, ''
        photo_is_guessed comment, guesser
        is_updated_per_flickr guesser
      end

      it 'creates the guesser if necessary' do
        comment = Comment.make
        set_time
        stub_person_request
        Comment.add_selected_answer comment.id, ''
        #noinspection RubyArgCount
        guess = Guess.includes(:person).find_by_photo_id comment.photo
        guess.person.flickrid.should == comment.flickrid
        guess.person.username.should == 'username_from_request'
        guess.person.pathalias.should == 'pathalias_from_request'
      end

      it 'handles a redundant username' do
        guesser = Person.make
        comment = Comment.make flickrid: guesser.flickrid,
          username: guesser.username, commented_at: Time.utc(2011)
        set_time
        stub_person_request
        Comment.add_selected_answer comment.id, guesser.username
        photo_is_guessed comment, guesser
        is_updated_per_flickr guesser
      end

      it 'gives the point to another, new user' do
        scorer_comment = Comment.make 'scorer',
          flickrid: 'scorer_flickrid', username: 'scorer_person_username'
        answer_comment = Comment.make 'answer', commented_at: Time.utc(2011)
        set_time
        stub_person_request
        Comment.add_selected_answer answer_comment.id, scorer_comment.username
        guesses = Guess.where photo: answer_comment.photo
        guesses.length.should == 1
        guess = guesses[0]
        guess.person.flickrid.should == scorer_comment.flickrid
        guess.person.username.should == 'username_from_request'
        guess.person.pathalias.should == 'pathalias_from_request'
        guess.comment_text.should == answer_comment.comment_text
        guess.commented_at.should == answer_comment.commented_at
        guess.added_at.should == @now
        guess.photo.game_status.should == 'found'
      end

      it 'gives the point to another, known user' do
        scorer = Person.make 'scorer'
        scorer_comment = Comment.make 'scorer',
          flickrid: scorer.flickrid, username: scorer.username
        answer_comment = Comment.make 'answer', commented_at: Time.utc(2011)
        set_time
        stub_person_request
        Comment.add_selected_answer answer_comment.id, scorer_comment.username
        photo_is_guessed answer_comment, scorer
        is_updated_per_flickr scorer
      end

      it "leaves alone an existing guess by the same guesser" do
        old_guess = Guess.make
        comment = Comment.make photo: old_guess.photo,
          flickrid: old_guess.person.flickrid, username: old_guess.person.username,
          commented_at: Time.utc(2011)
        set_time
        stub_person_request
        Comment.add_selected_answer comment.id, ''

        guesses = old_guess.photo.reload.guesses
        guesses.length.should == 2
        guesses.all? { |guess| guess.photo == old_guess.photo }.should be_true
        guesses.all? { |guess| guess.person == old_guess.person }.should be_true
        guesses.map(&:comment_text).should =~ [old_guess.comment_text, comment.comment_text]

      end

      it 'deletes an existing revelation' do
        guesser = Person.make
        comment = Comment.make flickrid: guesser.flickrid,
          username: guesser.username, commented_at: Time.utc(2011)
        Revelation.make photo: comment.photo
        stub_person_request
        Comment.add_selected_answer comment.id, ''
        Revelation.count.should == 0
      end

      it "blows up if an unknown username is specified" do
        comment = Comment.make
        lambda { Comment.add_selected_answer comment.id, 'unknown_username' }.should raise_error Photo::AddAnswerError
      end

      def stub_person_request
        # noinspection RubyArgCount
        stub(FlickrService.instance).people_get_info { {
          'person' => [{
            'username' => ['username_from_request'],
            'photosurl' => ['https://www.flickr.com/photos/pathalias_from_request/']
          }]
        } }
      end

      def photo_is_guessed(comment, guesser)
        guesses = Guess.where photo: comment.photo
        guesses.length.should == 1
        guess = guesses[0]
        guess.person.should == guesser
        guess.comment_text.should == comment.comment_text
        guess.commented_at.should == comment.commented_at
        guess.added_at.should == @now
        guess.photo.game_status.should == 'found'
      end

      def is_updated_per_flickr(guesser)
        guesser.reload
        guesser.username.should == 'username_from_request'
        guesser.pathalias.should == 'pathalias_from_request'
      end

    end

    # Specs of add_selected_answer call this immediately before calling add_selected_answer so
    # that it doesn't affect test objects' date attributes and assertions on
    # those attributes don't pass by accident
    def set_time
      # noinspection RubyArgCount
      stub(Time).now { @now }
    end

  end

  describe '.remove_revelation' do
    it 'removes a revelation' do
      revelation = Revelation.make
      photo = revelation.photo
      comment = Comment.make photo: photo,
        flickrid: photo.person.flickrid, username: photo.person.username,
        comment_text: revelation.comment_text
      Comment.remove_revelation comment.id
      photo.reload
      photo.game_status.should == 'unfound'
      Revelation.count.should == 0
    end

    it "doesn't delete the revealer's revelation of another photo with the same comment" do
      revelation1 = Revelation.make comment_text: 'identical'
      photo1 = revelation1.photo
      photo2 = Photo.make person: photo1.person
      revelation2 = Revelation.make photo: photo2, comment_text: 'identical'
      comment = Comment.make photo: photo1,
        flickrid: photo1.person.flickrid, username: photo1.person.username,
        comment_text: revelation1.comment_text
      Comment.remove_revelation comment.id
      Revelation.all.should == [ revelation2 ]
    end

  end

  describe '.remove_guess' do
    it 'removes a guess' do
      guess = Guess.make
      photo = guess.photo
      comment = Comment.make photo: photo,
        flickrid: guess.person.flickrid, username: guess.person.username,
        comment_text: guess.comment_text
      Comment.remove_guess comment.id
      photo.reload
      photo.game_status.should == 'unfound'
      Guess.count.should == 0
      owner_does_not_exist guess
    end

    it "leaves the photo found if there's another guess" do
      photo = Photo.make game_status: 'found'
      guess1 = Guess.make 1, photo: photo
      comment1 = Comment.make 1, photo: photo,
        flickrid: guess1.person.flickrid, username: guess1.person.username,
        comment_text: guess1.comment_text
      guess2 = Guess.make 2, photo: photo
      Comment.make 2, photo: photo,
        flickrid: guess2.person.flickrid, username: guess2.person.username,
        comment_text: guess2.comment_text
      Comment.remove_guess comment1.id
      photo.reload
      photo.game_status.should == 'found'
      Guess.all.should == [ guess2 ]
    end

    it "doesn't delete the guesser's guess of another photo with the same comment" do
      guess1 = Guess.make 1, comment_text: 'identical'
      guess2 = Guess.make 2, person: guess1.person, comment_text: guess1.comment_text
      comment = Comment.make photo: guess1.photo,
        flickrid: guess1.person.flickrid, username: guess1.person.username,
        comment_text: guess1.comment_text
      Comment.remove_guess comment.id
      Guess.all.should == [ guess2 ]
    end

  end

  describe '#is_by_poster' do
    it "returns true if the comment was made by the photo's poster" do
      photo = Photo.make
      comment = Comment.make photo: photo, flickrid: photo.person.flickrid
      comment.is_by_poster.should be_true
    end

    it "returns false if the comment was not made by the photo's poster" do
      Comment.make.is_by_poster.should be_false
    end

  end

  describe '#is_accepted_answer' do
    it "returns false if this comment has no revelations or guesses" do
      Comment.make.is_accepted_answer.should be_false
    end

    it "returns true if a revelation was created from this comment" do
      photo = Photo.make
      comment = Comment.make photo: photo, flickrid: photo.person.flickrid
      Revelation.make photo: photo, comment_text: comment.comment_text
      comment.is_accepted_answer.should be_true
    end

    it "returns false if the revelation is of another photo" do
      photo = Photo.make
      comment = Comment.make photo: photo, flickrid: photo.person.flickrid
      other_photo = Photo.make 'other', person: photo.person
      Revelation.make photo: other_photo, comment_text: comment.comment_text
      comment.is_accepted_answer.should be_false
    end

    it "returns false if the text doesn't match" do
      photo = Photo.make
      comment = Comment.make photo: photo, flickrid: photo.person.flickrid
      Revelation.make photo: photo, comment_text: "something else"
      comment.is_accepted_answer.should be_false
    end

    it "returns true if a guess was created from this comment" do
      person = Person.make
      comment = Comment.make flickrid: person.flickrid
      Guess.make photo: comment.photo, person: person, comment_text: comment.comment_text
      comment.is_accepted_answer.should be_true
    end

    it "returns false if the guess is of another photo" do
      person = Person.make
      comment = Comment.make flickrid: person.flickrid
      other_photo = Photo.make 'other', person: person
      Guess.make photo: other_photo, person: person, comment_text: comment.comment_text
      comment.is_accepted_answer.should be_false
    end

    it "returns false if the text doesn't match" do
      person = Person.make
      comment = Comment.make flickrid: person.flickrid
      Guess.make photo: comment.photo, person: person, comment_text: "something else"
      comment.is_accepted_answer.should be_false
    end

    it "returns false if the guess is by another person" do
      person = Person.make
      comment = Comment.make flickrid: person.flickrid
      Guess.make photo: comment.photo, comment_text: comment.comment_text
      comment.is_accepted_answer.should be_false
    end

  end

end
