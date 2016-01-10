describe PhotoStatisticsSupport do
  describe '.update_statistics' do
    describe "when updating other user comments" do
      it "counts comments" do
        comment = create :comment
        Photo.update_statistics
        comment.photo.reload
        expect(comment.photo.other_user_comments).to eq(1)
      end

      it "ignores comments by the poster" do
        photo = create :photo
        create :comment, photo: photo, flickrid: photo.person.flickrid, username: photo.person.username
        Photo.update_statistics
        photo.reload
        expect(photo.other_user_comments).to eq(0)
      end

      it "handles photos which go from nonzero to zero comments" do
        photo = create :photo, other_user_comments: 1
        Photo.update_statistics
        photo.reload
        expect(photo.other_user_comments).to eq(0)
      end

    end

    describe "when updating member comments" do
      it 'counts comments on guessed photos' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(1)
      end

      it 'ignores comments by the poster' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(0)
      end

      it 'ignores comments by non-members' do
        guess = create :guess
        create :comment, photo: guess.photo
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(0)
      end

      it 'counts comments other than the guess' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at - 5
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(2)
      end

      it 'ignores comments after the guess' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at + 5
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(1)
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = create :photo, member_comments: 1
        create :guess, photo: photo
        Photo.update_statistics
        photo.reload
        expect(photo.member_comments).to eq(0)
      end

    end

    describe "when updating member questions" do
      it 'counts questions on guessed photos' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at, comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(1)
      end

      it 'ignores questions by the poster' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username,
          comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(0)
      end

      it 'ignores questions by non-members' do
        guess = create :guess
        create :comment, photo: guess.photo, comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(0)
      end

      it 'counts questions other than the guess' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at - 5, comment_text: '?'
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at, comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(2)
      end

      it 'ignores questions after the guess' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at, comment_text: '?'
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at + 5, comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(1)
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = create :photo, member_questions: 1
        create :guess, photo: photo
        Photo.update_statistics
        photo.reload
        expect(photo.member_questions).to eq(0)
      end

    end

  end

  describe '#infer_geocodes' do
    let(:parser) do
      street_names = %w( 26TH VALENCIA )
      allow(Stcline).to receive(:multiword_street_names) { street_names }
      parser = double
      allow(LocationParser).to receive(:new).with(street_names) { parser }
      parser
    end

    let(:factory) { RGeo::Cartesian.preferred_factory }

    it "infers each guessed photo's lat+long from its guess" do
      answer = create :guess, comment_text: 'A parseable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      allow(parser).to receive(:parse).with(answer.comment_text) { [location] }
      allow(Stintersection).to receive(:geocode).with(location) { factory.point(-122, 37) }
      Photo.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(BigDecimal.new('37.0'))
      expect(answer.photo.inferred_longitude).to eq(BigDecimal.new('-122.0'))

    end

    it "infers each revealed photo's lat+long from its revelation" do
      answer = create :revelation, comment_text: 'A parseable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      allow(parser).to receive(:parse).with(answer.comment_text) { [location] }
      allow(Stintersection).to receive(:geocode).with(location) { factory.point(-122, 37) }
      Photo.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(BigDecimal.new('37.0'))
      expect(answer.photo.inferred_longitude).to eq(BigDecimal.new('-122.0'))

    end

    it "removes an existing inferred geocode if the comment can't be parsed" do
      photo = create :photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'An unparseable comment'
      allow(parser).to receive(:parse).with(answer.comment_text) { [] }
      Photo.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(nil)
      expect(answer.photo.inferred_longitude).to eq(nil)

    end

    it "removes an existing inferred geocode if the location can't be geocoded" do
      photo = create :photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'A parseable but not geocodable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      allow(parser).to receive(:parse).with(answer.comment_text) { [location] }
      allow(Stintersection).to receive(:geocode).with(location) { nil }
      Photo.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(nil)
      expect(answer.photo.inferred_longitude).to eq(nil)

    end

    it "removes an existing inferred geocode if the comment has multiple geocodable locations" do
      photo = create :photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'A comment with multiple gecodable locations'
      location1 = Intersection.new '25th and Valencia', '25th', nil, 'Valencia', nil
      location2 = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      allow(parser).to receive(:parse).with(answer.comment_text) { [location1, location2] }
      allow(Stintersection).to receive(:geocode).with(location1) { factory.point(37, -122) }
      allow(Stintersection).to receive(:geocode).with(location2) { factory.point(38, -122) }
      Photo.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(nil)
      expect(answer.photo.inferred_longitude).to eq(nil)

    end

  end

end
