describe AdminPhotosComment do
  describe '.add_selected_answer' do
    let(:now) { Time.utc 2010 }

    context "when adding a revelation" do
      let(:photo) { create :admin_photos_photo }

      it "adds a revelation" do
        comment = create :admin_photos_comment, photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        set_time
        AdminPhotosComment.add_selected_answer comment.id, ''
        photo_is_revealed_and_revelation_matches comment
      end

      it "handles a redundant username" do
        comment = create :admin_photos_comment, photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        set_time
        AdminPhotosComment.add_selected_answer comment.id, photo.person.username
        photo_is_revealed_and_revelation_matches comment
      end

      it "gets text from another user's comment" do
        comment = create :admin_photos_comment, photo: photo, commented_at: Time.utc(2011)
        set_time
        AdminPhotosComment.add_selected_answer comment.id, photo.person.username
        photo_is_revealed_and_revelation_matches comment
      end

      it "updates an existing revelation" do
        create :admin_photos_revelation, photo: photo
        comment = create :admin_photos_comment, photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        set_time
        AdminPhotosComment.add_selected_answer comment.id, ''
        photo_is_revealed_and_revelation_matches comment
      end

      def photo_is_revealed_and_revelation_matches(comment)
        revelations = AdminPhotosRevelation.where photo: comment.photo
        expect(revelations.length).to eq(1)
        revelation = revelations[0]
        expect(revelation.photo.game_status).to eq('revealed')
        expect(revelation.comment_text).to eq(comment.comment_text)
        expect(revelation.commented_at).to eq(comment.commented_at)
        expect(revelation.added_at).to eq(now)
      end

      it "deletes an existing guess" do
        comment = create :admin_photos_comment, photo: photo, flickrid: photo.person.flickrid,
          username: photo.person.username, commented_at: Time.utc(2011)
        create :admin_photos_guess, photo: photo
        AdminPhotosComment.add_selected_answer comment.id, ''
        expect(AdminPhotosGuess.any?).to be_falsy
      end

    end

    context "when adding a guess" do
      it "adds a guess and updates the guesser if necessary" do
        guesser = create :admin_photos_person
        comment = create :admin_photos_comment, flickrid: guesser.flickrid, username: guesser.username, commented_at: Time.utc(2011)
        set_time
        stub_person_request
        AdminPhotosComment.add_selected_answer comment.id, ''
        photo_is_guessed comment, guesser
        is_updated_per_flickr guesser
      end

      it "creates the guesser if necessary" do
        comment = create :admin_photos_comment
        set_time
        stub_person_request
        AdminPhotosComment.add_selected_answer comment.id, ''
        guesser = AdminPhotosGuess.includes(:person).find_by_photo_id(comment.photo).person
        expect(guesser.flickrid).to eq(comment.flickrid)
        has_attributes_per_flickr guesser
      end

      it "handles a redundant username" do
        guesser = create :admin_photos_person
        comment = create :admin_photos_comment, flickrid: guesser.flickrid, username: guesser.username, commented_at: Time.utc(2011)
        set_time
        stub_person_request
        AdminPhotosComment.add_selected_answer comment.id, guesser.username
        photo_is_guessed comment, guesser
        is_updated_per_flickr guesser
      end

      it "gives the point to another, new user" do
        scorer_comment = create :admin_photos_comment, flickrid: 'scorer_flickrid', username: 'scorer_person_username'
        answer_comment = create :admin_photos_comment, commented_at: Time.utc(2011)
        set_time
        stub_person_request
        AdminPhotosComment.add_selected_answer answer_comment.id, scorer_comment.username
        guesses = AdminPhotosGuess.where photo: answer_comment.photo
        expect(guesses.length).to eq(1)
        guess = guesses[0]
        expect(guess.person.flickrid).to eq(scorer_comment.flickrid)
        has_attributes_per_flickr guess.person
        expect(guess.comment_text).to eq(answer_comment.comment_text)
        expect(guess.commented_at).to eq(answer_comment.commented_at)
        expect(guess.added_at).to eq(now)
        expect(guess.photo.game_status).to eq('found')
      end

      it "gives the point to another, known user" do
        scorer = create :admin_photos_person
        scorer_comment = create :admin_photos_comment, flickrid: scorer.flickrid, username: scorer.username
        answer_comment = create :admin_photos_comment, commented_at: Time.utc(2011)
        set_time
        stub_person_request
        AdminPhotosComment.add_selected_answer answer_comment.id, scorer_comment.username
        photo_is_guessed answer_comment, scorer
        is_updated_per_flickr scorer
      end

      it "leaves alone an existing guess by the same guesser" do
        old_guess = create :admin_photos_guess, comment_text: "existing comment"
        comment = create :admin_photos_comment, photo: old_guess.photo,
          flickrid: old_guess.person.flickrid, username: old_guess.person.username,
          commented_at: Time.utc(2011), comment_text: "new comment"
        set_time
        stub_person_request
        AdminPhotosComment.add_selected_answer comment.id, ''

        guesses = old_guess.photo.reload.guesses
        expect(guesses.length).to eq(2)
        expect(guesses.all? { |guess| guess.photo == old_guess.photo }).to be_truthy
        expect(guesses.all? { |guess| guess.person == old_guess.person }).to be_truthy
        expect(guesses.map(&:comment_text)).to match_array([old_guess.comment_text, comment.comment_text])

      end

      it "deletes an existing revelation" do
        guesser = create :admin_photos_person
        comment = create :admin_photos_comment, flickrid: guesser.flickrid,
          username: guesser.username, commented_at: Time.utc(2011)
        create :admin_photos_revelation, photo: comment.photo
        stub_person_request
        AdminPhotosComment.add_selected_answer comment.id, ''
        expect(AdminPhotosRevelation.any?).to be_falsy
      end

      it "blows up if an unknown username is specified" do
        comment = create :admin_photos_comment
        expect { AdminPhotosComment.add_selected_answer comment.id, 'unknown_username' }.to raise_error AdminPhotosPhoto::AddAnswerError
      end

      def stub_person_request
        allow(FlickrService.instance).to receive(:people_get_info) do
          {
            'person' => [{
              'username' => ['username_from_request'],
              'realname' => ['realname_from_request'],
              'photosurl' => ['https://www.flickr.com/photos/pathalias_from_request/'],
              'ispro' => '1'
            }]
          }
        end
      end

      def photo_is_guessed(comment, guesser)
        guesses = AdminPhotosGuess.where photo: comment.photo
        expect(guesses.length).to eq(1)
        guess = guesses[0]
        expect(guess.person).to eq(guesser)
        expect(guess.comment_text).to eq(comment.comment_text)
        expect(guess.commented_at).to eq(comment.commented_at)
        expect(guess.added_at).to eq(now)
        expect(guess.photo.game_status).to eq('found')
      end

      def is_updated_per_flickr(guesser)
        guesser.reload
        has_attributes_per_flickr(guesser)
      end

      def has_attributes_per_flickr(guesser)
        expect(guesser.username).to eq('username_from_request')
        expect(guesser.realname).to eq('realname_from_request')
        expect(guesser.pathalias).to eq('pathalias_from_request')
        expect(guesser.ispro).to be true
      end

    end

    # Specs of add_selected_answer call this immediately before calling add_selected_answer so
    # that it doesn't affect test objects' date attributes and assertions on
    # those attributes don't pass by accident
    def set_time
      allow(Time).to receive(:now) { now }
    end

  end

  describe '.remove_revelation' do
    it "removes a revelation" do
      revelation = create :admin_photos_revelation
      photo = revelation.photo
      comment = create :admin_photos_comment, photo: photo,
        flickrid: photo.person.flickrid, username: photo.person.username,
        comment_text: revelation.comment_text
      AdminPhotosComment.remove_revelation comment.id
      photo.reload
      expect(photo.game_status).to eq('unfound')
      expect(AdminPhotosRevelation.count).to eq(0)
    end

    it "doesn't delete the revealer's revelation of another photo with the same comment" do
      revelation1 = create :admin_photos_revelation, comment_text: 'identical'
      photo1 = revelation1.photo
      photo2 = create :admin_photos_photo, person: photo1.person
      revelation2 = create :admin_photos_revelation, photo: photo2, comment_text: 'identical'
      comment = create :admin_photos_comment, photo: photo1,
        flickrid: photo1.person.flickrid, username: photo1.person.username,
        comment_text: revelation1.comment_text
      AdminPhotosComment.remove_revelation comment.id
      expect(AdminPhotosRevelation.all).to eq([revelation2])
    end

  end

  describe '.remove_guess' do
    it "removes a guess" do
      guess = create :admin_photos_guess
      photo = guess.photo
      comment = create :admin_photos_comment, photo: photo,
        flickrid: guess.person.flickrid, username: guess.person.username,
        comment_text: guess.comment_text
      AdminPhotosComment.remove_guess comment.id
      photo.reload
      expect(photo.game_status).to eq('unfound')
      expect(AdminPhotosGuess.count).to eq(0)
    end

    it "leaves the photo found if there's another guess" do
      photo = create :admin_photos_photo, game_status: 'found'
      guess1 = create :admin_photos_guess, photo: photo
      comment1 = create :admin_photos_comment, photo: photo,
        flickrid: guess1.person.flickrid, username: guess1.person.username,
        comment_text: guess1.comment_text
      guess2 = create :admin_photos_guess, photo: photo
      create :admin_photos_comment, photo: photo,
        flickrid: guess2.person.flickrid, username: guess2.person.username,
        comment_text: guess2.comment_text
      AdminPhotosComment.remove_guess comment1.id
      photo.reload
      expect(photo.game_status).to eq('found')
      expect(AdminPhotosGuess.all).to eq([guess2])
    end

    it "doesn't delete the guesser's guess of another photo with the same comment" do
      guess1 = create :admin_photos_guess, comment_text: 'identical'
      guess2 = create :admin_photos_guess, person: guess1.person, comment_text: guess1.comment_text
      comment = create :admin_photos_comment, photo: guess1.photo,
        flickrid: guess1.person.flickrid, username: guess1.person.username,
        comment_text: guess1.comment_text
      AdminPhotosComment.remove_guess comment.id
      expect(AdminPhotosGuess.all).to eq([guess2])
    end

  end

  describe '#by_poster?' do
    it "returns true if the comment was made by the photo's poster" do
      photo = create :admin_photos_photo
      comment = create :admin_photos_comment, photo: photo, flickrid: photo.person.flickrid
      expect(comment.by_poster?).to be_truthy
    end

    it "returns false if the comment was not made by the photo's poster" do
      expect(create(:admin_photos_comment).by_poster?).to be_falsy
    end

  end

  describe '#accepted_answer?' do
    it "returns false if this comment has no revelations or guesses" do
      expect(create(:admin_photos_comment).accepted_answer?).to be_falsy
    end

    context "when photo is revealed" do
      let(:photo) { create :admin_photos_photo }
      let(:comment) { create :admin_photos_comment, photo: photo, flickrid: photo.person.flickrid }

      it "returns true if a revelation was created from this comment" do
        create :admin_photos_revelation, photo: photo, comment_text: comment.comment_text
        expect(comment.accepted_answer?).to be_truthy
      end

      it "returns false if the revelation is of another photo" do
        other_photo = create :admin_photos_photo, person: photo.person
        create :admin_photos_revelation, photo: other_photo, comment_text: comment.comment_text
        expect(comment.accepted_answer?).to be_falsy
      end

      it "returns false if the text doesn't match" do
        create :admin_photos_revelation, photo: photo, comment_text: "something else"
        expect(comment.accepted_answer?).to be_falsy
      end

    end

    context "when photo is guessed" do
      let(:person) { create :admin_photos_person }
      let(:comment) { create :admin_photos_comment, flickrid: person.flickrid }

      it "returns true if a guess was created from this comment" do
        create :admin_photos_guess, photo: comment.photo, person: person, comment_text: comment.comment_text
        expect(comment.accepted_answer?).to be_truthy
      end

      it "returns false if the guess is of another photo" do
        other_photo = create :admin_photos_photo, person: person
        create :admin_photos_guess, photo: other_photo, person: person, comment_text: comment.comment_text
        expect(comment.accepted_answer?).to be_falsy
      end

      it "returns false if the text doesn't match" do
        create :admin_photos_guess, photo: comment.photo, person: person, comment_text: "something else"
        expect(comment.accepted_answer?).to be_falsy
      end

      it "returns false if the guess is by another person" do
        create :admin_photos_guess, photo: comment.photo, comment_text: comment.comment_text
        expect(comment.accepted_answer?).to be_falsy
      end

    end

  end

end
