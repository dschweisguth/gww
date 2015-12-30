describe PhotoAdminPhotosSupport do
  describe '.inaccessible' do
    before do
      create :flickr_update, created_at: Time.utc(2011)
    end

    it "lists photos not seen since the last update" do
      photo = create :photo, seen_at: Time.utc(2010)
      expect(Photo.inaccessible).to eq([ photo ])
    end

    it "includes unconfirmed photos" do
      photo = create :photo, seen_at: Time.utc(2010), game_status: 'unconfirmed'
      expect(Photo.inaccessible).to eq([ photo ])
    end

    it "ignores photos seen since the last update" do
      create :photo, seen_at: Time.utc(2011)
      expect(Photo.inaccessible).to eq([])
    end

    it "ignores statuses other than unfound and unconfirmed" do
      create :photo, seen_at: Time.utc(2010), game_status: 'found'
      expect(Photo.inaccessible).to eq([])
    end

  end

  describe '.multipoint' do
    let(:photo) { create :photo }

    it 'returns photos for which more than one person got a point' do
      create_list :guess, 2, photo: photo
      expect(Photo.multipoint).to eq([ photo ])
    end

    it 'ignores photos for which only one person got a point' do
      create :guess, photo: photo
      expect(Photo.multipoint).to eq([])
    end

  end

  describe '.change_game_status' do
    let(:photo) { create :photo }

    it "changes the photo's status" do
      Photo.change_game_status photo.id, 'unconfirmed'
      photo.reload
      expect(photo.game_status).to eq('unconfirmed')
    end

    it 'deletes existing guesses' do
      create :guess, photo: photo
      Photo.change_game_status photo.id, 'unconfirmed'
      expect(Guess.count).to eq(0)
    end

    it 'deletes existing revelations' do
      create :revelation, photo: photo
      Photo.change_game_status photo.id, 'unconfirmed'
      expect(Revelation.count).to eq(0)
    end

  end

  describe '.add_entered_answer' do
    let(:now) { Time.utc 2010 }
    let(:photo) { create :photo }

    context 'when adding a revelation' do
      it 'needs a non-empty comment text' do
        expect { Photo.add_entered_answer photo.id, photo.person.username, '' }.to raise_error ArgumentError
      end

      it 'adds a revelation' do
        set_time
        Photo.add_entered_answer photo.id, photo.person.username, 'comment text'
        is_revealed photo, 'comment text'
      end

      it "defaults to the photo's owner" do
        set_time
        Photo.add_entered_answer photo.id, '', 'comment text'
        is_revealed photo, 'comment text'
      end

      it 'updates an existing revelation' do
        create :revelation, photo: photo
        set_time
        Photo.add_entered_answer photo.id, photo.person.username, 'new comment text'
        is_revealed photo, 'new comment text'
      end

      def is_revealed(photo, comment_text)
        revelation = photo.revelation.reload
        expect(revelation.photo.game_status).to eq('revealed')
        expect(revelation.comment_text).to eq(comment_text)
        expect(revelation.commented_at).to eq(now)
        expect(revelation.added_at).to eq(now)
      end

      it 'deletes an existing guess' do
        create :guess, photo: photo
        Photo.add_entered_answer photo.id, photo.person.username, 'comment text'
        expect(Guess.any?).to be_falsy
      end

    end

    context 'when adding a guess' do
      it 'adds a guess and updates the guesser if necessary' do
        guesser = create :person
        set_time
        stub_person_request
        Photo.add_entered_answer photo.id, guesser.username, 'comment text'

        photo.reload
        expect(photo.guesses.length).to eq(1)
        guess = photo.guesses.first
        expect(guess.person).to eq(guesser)
        expect(guess.comment_text).to eq('comment text')
        expect(guess.commented_at).to eq(now)
        expect(guess.added_at).to eq(now)
        expect(guess.photo.game_status).to eq('found')

        guesser.reload
        expect(guesser.username).to eq('username_from_request')
        expect(guesser.pathalias).to eq('pathalias_from_request')

      end

      it 'creates the guesser if necessary' do
        comment = create :comment
        set_time
        stub_person_request
        Photo.add_entered_answer photo.id, comment.username, 'comment text'
        guess = Guess.includes(:person).find_by_photo_id photo
        expect(guess.person.flickrid).to eq(comment.flickrid)
        expect(guess.person.username).to eq('username_from_request')
        expect(guess.person.pathalias).to eq('pathalias_from_request')
      end

      it "leaves alone an existing guess by the same guesser" do
        old_guess = create :guess, photo: photo
        set_time
        stub_person_request
        Photo.add_entered_answer photo.id, old_guess.person.username, 'new comment text'

        guesses = photo.reload.guesses
        expect(guesses.length).to eq(2)
        expect(guesses.all? { |guess| guess.photo == photo }).to be_truthy
        expect(guesses.all? { |guess| guess.person == old_guess.person }).to be_truthy
        expect(guesses.map(&:comment_text)).to match_array([old_guess.comment_text, 'new comment text'])

      end

      it 'deletes an existing revelation' do
        create :revelation, photo: photo
        guesser = create :person
        stub_person_request
        Photo.add_entered_answer photo.id, guesser.username, 'comment text'
        expect(Revelation.any?).to be_falsy
      end

      it "blows up if an unknown username is specified" do
        expect { Photo.add_entered_answer photo.id, 'unknown_username', 'comment text' }.to raise_error Photo::AddAnswerError
      end

      def stub_person_request
        allow(FlickrService.instance).to receive(:people_get_info) do
          {
            'person' => [{
              'username' => ['username_from_request'],
              'photosurl' => ['https://www.flickr.com/photos/pathalias_from_request/']
            }]
          }
        end
      end

    end

    # Specs of add_entered_answer call this immediately before calling add_selected_answer so
    # that it doesn't affect test objects' date attributes and assertions on those attributes don't pass by accident
    def set_time
      allow(Time).to receive(:now) { now }
    end

  end

  describe '#ready_to_score?' do
    %w(unfound unconfirmed).each do |game_status|
      %w(foundinSF revealedinSF).each do |raw|
        it "returns true if the photo is #{game_status} and has a #{raw} tag" do
          photo = create :photo, game_status: game_status
          create :tag, photo: photo, raw: raw
          expect(photo.ready_to_score?).to be_truthy
        end
      end
    end

    it "ignores tag case" do
      photo = create :photo, game_status: 'unfound'
      create :tag, photo: photo, raw: 'FOUNDINSF'
      expect(photo.ready_to_score?).to be_truthy
    end

    it "returns false if the photo is neither unfound nor unconfirmed" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'foundinSF'
      expect(photo.ready_to_score?).to be_falsy
    end

    it "returns false if the photo does not have a foundinSF or revealedinSF tag" do
      photo = create :photo, game_status: 'unfound'
      create :tag, photo: photo, raw: 'unfoundinSF'
      expect(photo.ready_to_score?).to be_falsy
    end

  end

  describe '#game_status_tags' do
    let(:photo) { create :photo }

    it "returns the photo's game status tags" do
      %w(unfoundinSF foundinSF revealedinSF).each do |raw|
        create :tag, photo: photo, raw: raw
      end
      expect(photo.game_status_tags.map(&:raw)).to eq(%w(unfoundinSF foundinSF revealedinSF))
    end

    it "is case-insensitive" do
      %w(UNFOUNDINSF FOUNDINSF REVEALEDINSF).each do |raw|
        create :tag, photo: photo, raw: raw
      end
      expect(photo.game_status_tags.map(&:raw)).to eq(%w(UNFOUNDINSF FOUNDINSF REVEALEDINSF))
    end

    it "ignores non-game-status tags" do
      create :tag, photo: photo
      expect(photo.game_status_tags).to be_empty
    end

  end

end
