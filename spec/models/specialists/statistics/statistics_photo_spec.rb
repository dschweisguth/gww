describe StatisticsPhoto do
  let(:factory) { RGeo::Cartesian.preferred_factory }

  describe '.update_statistics' do
    context "when updating other user comments" do
      it "counts comments" do
        comment = create :comment
        StatisticsPhoto.update_statistics
        comment.photo.reload
        expect(comment.photo.other_user_comments).to eq(1)
      end

      it "ignores comments by the poster" do
        photo = create :statistics_photo
        create :comment, photo: photo, flickrid: photo.person.flickrid, username: photo.person.username
        StatisticsPhoto.update_statistics
        photo.reload
        expect(photo.other_user_comments).to eq(0)
      end

      it "handles photos which go from nonzero to zero comments" do
        photo = create :statistics_photo, other_user_comments: 1
        StatisticsPhoto.update_statistics
        photo.reload
        expect(photo.other_user_comments).to eq(0)
      end

    end

    context "when updating member comments" do
      # In most of the tests in this section, reload the guess to run commented_at through the database
      # to avoid failures due to different treatment of fractional seconds

      it "counts comments on guessed photos" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(1)
      end

      it "ignores comments by the poster" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(0)
      end

      it "ignores comments by non-members" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(0)
      end

      it "counts comments other than the guess" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at - 5
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(2)
      end

      it "ignores comments after the guess" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at + 5
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_comments).to eq(1)
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = create :statistics_photo, member_comments: 1
        create :guess, photo: photo
        StatisticsPhoto.update_statistics
        photo.reload
        expect(photo.member_comments).to eq(0)
      end

    end

    context "when updating member questions" do
      # In most of the tests in this section, reload the guess to run commented_at through the database
      # to avoid failures due to different treatment of fractional seconds

      it "counts questions on guessed photos" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at, comment_text: '?'
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(1)
      end

      it "ignores questions by the poster" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username,
          comment_text: '?'
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(0)
      end

      it "ignores questions by non-members" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo, comment_text: '?'
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(0)
      end

      it "counts questions other than the guess" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at - 5, comment_text: '?'
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at, comment_text: '?'
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(2)
      end

      it "ignores questions after the guess" do
        guess = (create :guess).tap &:reload
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at, comment_text: '?'
        create :comment, photo: guess.photo,
          flickrid: guess.person.flickrid, username: guess.person.username,
          commented_at: guess.commented_at + 5, comment_text: '?'
        StatisticsPhoto.update_statistics
        guess.photo.reload
        expect(guess.photo.member_questions).to eq(1)
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = create :statistics_photo, member_questions: 1
        create :guess, photo: photo
        StatisticsPhoto.update_statistics
        photo.reload
        expect(photo.member_questions).to eq(0)
      end

    end

  end

  describe '.infer_geocodes' do
    let(:location) { Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil }

    let(:parser) do
      allow(Stcline).to receive(:multiword_street_names).and_return([])
      double.tap do |parser|
        allow(LocationParser).to receive(:new).with([]).and_return(parser)
      end
    end

    it "infers each guessed photo's lat+long from its guess" do
      answer = create :guess, comment_text: 'A parseable comment'
      allow(parser).to receive(:parse).with(answer.comment_text).and_return([location])
      allow(Stintersection).to receive(:geocode).with(location).and_return(factory.point(-122, 37))
      StatisticsPhoto.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(BigDecimal('37.0'))
      expect(answer.photo.inferred_longitude).to eq(BigDecimal('-122.0'))

    end

    it "infers each revealed photo's lat+long from its revelation" do
      answer = create :revelation, comment_text: 'A parseable comment'
      allow(parser).to receive(:parse).with(answer.comment_text).and_return([location])
      allow(Stintersection).to receive(:geocode).with(location).and_return(factory.point(-122, 37))
      StatisticsPhoto.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to eq(BigDecimal('37.0'))
      expect(answer.photo.inferred_longitude).to eq(BigDecimal('-122.0'))

    end

    it "removes an existing inferred geocode if the comment can't be parsed" do
      photo = create :statistics_photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'An unparseable comment'
      allow(parser).to receive(:parse).with(answer.comment_text).and_return([])
      StatisticsPhoto.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to be_nil
      expect(answer.photo.inferred_longitude).to be_nil

    end

    it "removes an existing inferred geocode if the location can't be geocoded" do
      photo = create :statistics_photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'A parseable but not geocodable comment'
      allow(parser).to receive(:parse).with(answer.comment_text).and_return([location])
      allow(Stintersection).to receive(:geocode).with(location).and_return(nil)
      StatisticsPhoto.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to be_nil
      expect(answer.photo.inferred_longitude).to be_nil

    end

    it "removes an existing inferred geocode if the comment has multiple geocodable locations" do
      photo = create :statistics_photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'A comment with multiple geocodable locations'
      location2 = Intersection.new '25th and Valencia', '25th', nil, 'Valencia', nil
      allow(parser).to receive(:parse).with(answer.comment_text).and_return([location, location2])
      allow(Stintersection).to receive(:geocode).with(location).and_return(factory.point(37, -122))
      allow(Stintersection).to receive(:geocode).with(location2).and_return(factory.point(38, -122))
      StatisticsPhoto.infer_geocodes

      answer.photo.reload
      expect(answer.photo.inferred_latitude).to be_nil
      expect(answer.photo.inferred_longitude).to be_nil

    end

  end

  describe '#update_geocode!' do
    let(:photo) { create :statistics_photo, inferred_latitude: 37, inferred_longitude: -122 }

    it "updates an existing geocode if the newly inferred geocode differs only in latitude" do
      photo.update_geocode! factory.point(-122, 38)

      expect(photo.inferred_latitude).to eq(BigDecimal('38.0'))
      expect(photo.inferred_longitude).to eq(BigDecimal('-122.0'))

    end

    it "updates an existing geocode if the newly inferred geocode differs only in longitude" do
      photo.update_geocode! factory.point(-123, 37)

      expect(photo.inferred_latitude).to eq(BigDecimal('37.0'))
      expect(photo.inferred_longitude).to eq(BigDecimal('-123.0'))

    end

    it "doesn't update an existing geocode if the newly inferred geocode is identical" do
      allow(photo).to receive(:update!)
      photo.update_geocode! factory.point(-122, 37)
      StatisticsPhoto.infer_geocodes

      expect(photo).not_to have_received(:update!)
    end

  end

end
