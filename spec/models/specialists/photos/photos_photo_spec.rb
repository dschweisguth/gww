describe PhotosPhoto do
  describe '.all_sorted_and_paginated' do
    it "returns photos sorted by username" do
      all_sorted_and_paginated_reverses_photos('username',
        { username: 'z' }, { dateadded: Time.utc(2011) },
        { username: 'a' }, { dateadded: Time.utc(2010) })
    end

    it "ignores case" do
      all_sorted_and_paginated_reverses_photos('username',
        { username: 'Z' }, { dateadded: Time.utc(2011) },
        { username: 'a' }, { dateadded: Time.utc(2010) })
    end

    it "returns photos sorted by username, dateadded" do
      person = create :person
      photo1 = create :photos_photo, person: person, dateadded: Time.utc(2010)
      photo2 = create :photos_photo, person: person, dateadded: Time.utc(2011)
      expect(PhotosPhoto.all_sorted_and_paginated('username', '+', 1, 2)).to eq([photo2, photo1])
    end

    it "returns photos sorted by dateadded" do
      all_sorted_and_paginated_reverses_photos('date-added',
        { username: 'a' }, { dateadded: Time.utc(2010) },
        { username: 'z' }, { dateadded: Time.utc(2011) })
    end

    it "returns photos sorted by dateadded, username" do
      all_sorted_and_paginated_reverses_photos('date-added',
        { username: 'z' }, { dateadded: Time.utc(2011) },
        { username: 'a' }, { dateadded: Time.utc(2011) })
    end

    it "returns photos sorted by lastupdate" do
      all_sorted_and_paginated_reverses_photos('last-updated',
        { username: 'a' }, { lastupdate: Time.utc(2010) },
        { username: 'z' }, { lastupdate: Time.utc(2011) })
    end

    it "returns photos sorted by lastupdate, username" do
      all_sorted_and_paginated_reverses_photos('last-updated',
        { username: 'z' }, { lastupdate: Time.utc(2011) },
        { username: 'a' }, { lastupdate: Time.utc(2011) })
    end

    it "returns photos sorted by views" do
      all_sorted_and_paginated_reverses_photos('views',
        { username: 'a' }, { views: 0 },
        { username: 'z' }, { views: 1 })
    end

    it "returns photos sorted by views, username" do
      all_sorted_and_paginated_reverses_photos('views',
        { username: 'z' }, { views: 0 },
        { username: 'a' }, { views: 0 })
    end

    it "returns photos sorted by faves" do
      all_sorted_and_paginated_reverses_photos('faves',
        { username: 'a' }, { faves: 0 },
        { username: 'z' }, { faves: 1 })
    end

    it "returns photos sorted by faves, username" do
      all_sorted_and_paginated_reverses_photos('faves',
        { username: 'z' }, { faves: 0 },
        { username: 'a' }, { faves: 0 })
    end

    it "returns photos sorted by comments" do
      all_sorted_and_paginated_reverses_photos('comments',
        { username: 'a' }, { other_user_comments: 0 },
        { username: 'z' }, { other_user_comments: 1 })
    end

    it "returns photos sorted by comments, username" do
      all_sorted_and_paginated_reverses_photos('comments',
        { username: 'z' }, { other_user_comments: 0 },
        { username: 'a' }, { other_user_comments: 0 })
    end

    it "returns photos sorted by member_comments" do
      all_sorted_and_paginated_reverses_photos('member-comments',
        { username: 'a' }, { member_comments: 0, dateadded: Time.utc(2011) },
        { username: 'z' }, { member_comments: 1, dateadded: Time.utc(2010) })
    end

    it "returns photos sorted by member_comments, dateadded" do
      all_sorted_and_paginated_reverses_photos('member-comments',
        { username: 'a' }, { member_comments: 0, dateadded: Time.utc(2010) },
        { username: 'z' }, { member_comments: 0, dateadded: Time.utc(2011) })
    end

    it "returns photos sorted by member_comments, dateadded, username" do
      all_sorted_and_paginated_reverses_photos('member-comments',
        { username: 'z' }, { member_comments: 0, dateadded: Time.utc(2011) },
        { username: 'a' }, { member_comments: 0, dateadded: Time.utc(2011) })
    end

    it "returns photos sorted by member_questions" do
      all_sorted_and_paginated_reverses_photos('member-questions',
        { username: 'a' }, { member_questions: 0, dateadded: Time.utc(2011) },
        { username: 'z' }, { member_questions: 1, dateadded: Time.utc(2010) })
    end

    it "returns photos sorted by member_questions, dateadded" do
      all_sorted_and_paginated_reverses_photos('member-questions',
        { username: 'a' }, { member_questions: 0, dateadded: Time.utc(2010) },
        { username: 'z' }, { member_questions: 0, dateadded: Time.utc(2011) })
    end

    it "returns photos sorted by member_questions, dateadded, username" do
      all_sorted_and_paginated_reverses_photos('member-questions',
        { username: 'z' }, { member_questions: 0, dateadded: Time.utc(2011) },
        { username: 'a' }, { member_questions: 0, dateadded: Time.utc(2011) })
    end

    def all_sorted_and_paginated_reverses_photos(sorted_by,
      person_1_options, photo_1_options, person_2_options, photo_2_options)

      person1 = create :person, person_1_options
      photo1 = create :photos_photo, photo_1_options.merge(person: person1)
      person2 = create :person, person_2_options
      photo2 = create :photos_photo, photo_2_options.merge(person: person2)
      expect(PhotosPhoto.all_sorted_and_paginated(sorted_by, '+', 1, 2)).to eq([photo2, photo1])

    end

    it "paginates" do
      create_list :photo, 3
      expect(PhotosPhoto.all_sorted_and_paginated('username', '+', 1, 2).length).to eq(2)
    end

  end

  describe '.all_for_map' do
    let(:bounds) { Bounds.new 37.70571, 37.820904, -122.514381, -122.35714 }

    it "returns an unfound photo" do
      photo = build :photos_photo, latitude: 37, longitude: -122
      allow(PhotosPhoto).to receive(:mapped).with(bounds, 2) { [photo] }
      allow(PhotosPhoto).to receive(:oldest) { build :photos_photo, dateadded: 1.day.ago }
      expect(PhotosPhoto.all_for_map(bounds, 1)).to eq(
        partial: false,
        bounds: bounds,
        photos: [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => Color::Yellow.scaled(0, 0, 0),
            'symbol' => '?'
          }
        ]
      )
    end

    it "handles no photos" do
      allow(PhotosPhoto).to receive(:mapped).with(bounds, 2) { [] }
      allow(PhotosPhoto).to receive(:oldest) { nil }
      expect(PhotosPhoto.all_for_map(bounds, 1)).to eq(
        partial: false,
        bounds: bounds,
        photos: []
      )
    end

    it "returns no more than a maximum number of photos" do
      photo = build :photos_photo, latitude: 37, longitude: -122
      oldest_photo = build :photos_photo, dateadded: 1.day.ago
      allow(PhotosPhoto).to receive(:mapped).with(bounds, 2) { [photo, oldest_photo] }
      allow(PhotosPhoto).to receive(:oldest) { oldest_photo }
      expect(PhotosPhoto.all_for_map(bounds, 1)).to eq(
        partial: true,
        bounds: bounds,
        photos: [
          {
            'id' => photo.id,
            'latitude' => photo.latitude,
            'longitude' => photo.longitude,
            'color' => Color::Yellow.scaled(0, 0, 0),
            'symbol' => '?'
          }
        ]
      )
    end

  end

  describe '.search' do
    context "when searching for posts" do
      it "returns all photos" do
        create :photos_photo
        expect(search.length).to eq(1)
      end

      context "when specifying done_by" do
        it "returns a photo posted by the person with the given username" do
          photo = create :photos_photo
          expect(search(done_by: photo.person.username).length).to eq(1)
        end

        it "ignores a photo posted by a person with a different username" do
          create :photos_photo
          expect(search(done_by: 'xyz').length).to eq(0)
        end

      end

      context "when specifying text" do
        %i(title description).each do |attr|
          it "returns a photo whose #{attr} contains the given text" do
            create :photos_photo, attr => 'one two three'
            expect(photos_which_mention('two').length).to eq(1)
          end

          it "returns a photo whose #{attr} contains the given text in any case" do
            create :photos_photo, attr => 'ONE TWO THREE'
            expect(photos_which_mention('two').length).to eq(1)
          end

          it "returns a photo whose #{attr} contains the given text regardless of the case of the search term" do
            create :photos_photo, attr => 'one two three'
            expect(photos_which_mention('TWO').length).to eq(1)
          end

          it "ignores a photo whose #{attr} contains the given text, but not as a separate word" do
            create :photos_photo, title: 'onetwothree'
            expect(photos_which_mention('two').length).to eq(0)
          end

        end

        it "ignores a photo that has all the terms but in different attributes" do
          create :photos_photo, title: 'one two three', description: 'four five six'
          expect(photos_which_mention('two', 'five').length).to eq(0)
        end

        it "returns a photo with a tag that contains the given text" do
          create :tag, raw: 'one two three'
          expect(photos_which_mention('two').length).to eq(1)
        end

        it "returns a photo with a tag that contains the given text in any case" do
          create :tag, raw: 'ONE TWO THREE'
          expect(photos_which_mention('two').length).to eq(1)
        end

        it "returns a photo with a tag that contains the given text regardless of the case of the search term" do
          create :tag, raw: 'one two three'
          expect(photos_which_mention('TWO').length).to eq(1)
        end

        it "returns a photo that has all the terms but in different tags" do
          photo = create :photos_photo
          create :tag, photo: photo, raw: 'one two three'
          create :tag, photo: photo, raw: 'four five six'
          expect(photos_which_mention('two', 'four').length).to eq(1)
        end

        it "ignores a photo with a tag that contains the given text, but not as a separate word" do
          create :tag, raw: 'onetwothree'
          expect(photos_which_mention('two').length).to eq(0)
        end

        it "doesn't return all photos when a tag matches, just the one with the tag" do
          photo = create :photos_photo
          create :tag, photo: photo, raw: 'one two three'
          create :tag
          expect(photos_which_mention('two')).to eq([photo])
        end

        it "returns a photo with a comment that contains the given text" do
          create :comment, comment_text: 'one two three'
          expect(photos_which_mention('two').length).to eq(1)
        end

        it "returns a photo with a comment that contains the given text in any case" do
          create :comment, comment_text: 'ONE TWO THREE'
          expect(photos_which_mention('two').length).to eq(1)
        end

        it "returns a photo with a comment that contains the given text regardless of the case of the search term" do
          create :comment, comment_text: 'one two three'
          expect(photos_which_mention('TWO').length).to eq(1)
        end

        it "ignores a photo that has all the terms but in different comments" do
          photo = create :photos_photo
          create :comment, photo: photo, comment_text: 'one two three'
          create :comment, photo: photo, comment_text: 'four five six'
          expect(photos_which_mention('two', 'four').length).to eq(0)
        end

        it "ignores a photo with a comment that contains the given text, but not as a separate word" do
          create :comment, comment_text: 'onetwothree'
          expect(photos_which_mention('two').length).to eq(0)
        end

        it "doesn't return all photos when a comment matches, just the one with the comment" do
          photo = create :photos_photo
          create :comment, photo: photo, comment_text: 'one two three'
          create :comment
          expect(photos_which_mention('two')).to eq([photo])
        end

        it "searches for multiple terms" do
          create :photos_photo, title: 'one two three four five'
          expect(photos_which_mention('two', 'four').length).to eq(1)
        end

        it "ignores a photo that has only one of multiple terms" do
          create :photos_photo, title: 'one two three'
          expect(photos_which_mention('two', 'four').length).to eq(0)
        end

        it "searches for multiple groups in different attributes" do
          create :photos_photo, title: 'one two three', description: 'four five six'
          expect(search(text: [['two'], ['five']]).length).to eq(1)
        end

        it "ignores a photo none of whose title, description, tags or comments contains the given text" do
          create :photos_photo
          expect(photos_which_mention('Fort Point').length).to eq(0)
        end

        # It is a known bug that this method finds matches in HTML tag names and attributes. Fixing that would be hard.

        def photos_which_mention(*text)
          search text: [text]
        end

      end

      context "when specifying game_status" do
        it "returns a photo with the given status" do
          create :photos_photo, game_status: 'found'
          expect(search(game_status: %w(found)).length).to eq(1)
        end

        it "searches for photos with any of multiple statuses" do
          create :photos_photo, game_status: 'found'
          create :photos_photo, game_status: 'revealed'
          expect(search(game_status: %w(found revealed)).length).to eq(2)
        end

        it "ignores a photo with a different status" do
          create :photos_photo, game_status: 'found'
          expect(search(game_status: %w(unfound)).length).to eq(0)
        end

      end

      it "searches in a date range" do
        photos = [1, 2, 3].map { |day| create :photos_photo, dateadded: Time.utc(2014, 1, day) }
        expect(search(from_date: Time.utc(2014, 1, 2), to_date: Time.utc(2014, 1, 2))).to eq([photos[1]])
      end

      it "searches by more than one criterion" do
        photo1 = create :photos_photo, game_status: 'found'
        create :photos_photo, person: photo1.person
        create :photos_photo, game_status: 'found'
        expect(search(game_status: 'found', done_by: photo1.person.username).length).to eq(1)
      end

      it "sorts by last-updated, -" do
        photo1 = create :photos_photo, lastupdate: Time.utc(2012)
        photo2 = create :photos_photo, lastupdate: Time.utc(2013)
        expect(search(sorted_by: 'last-updated')).to eq([photo2, photo1])
      end

      it "sorts by last-updated, +" do
        photo1 = create :photos_photo, lastupdate: Time.utc(2013)
        photo2 = create :photos_photo, lastupdate: Time.utc(2012)
        expect(search(sorted_by: 'last-updated', direction: '+')).to eq([photo2, photo1])
      end

      it "sorts by date-added, -" do
        photo1 = create :photos_photo, dateadded: Time.utc(2012)
        photo2 = create :photos_photo, dateadded: Time.utc(2013)
        expect(search(sorted_by: 'date-added')).to eq([photo2, photo1])
      end

      it "sorts by date-added, +" do
        photo1 = create :photos_photo, dateadded: Time.utc(2013)
        photo2 = create :photos_photo, dateadded: Time.utc(2012)
        expect(search(sorted_by: 'date-added', direction: '+')).to eq([photo2, photo1])
      end

      it "sorts by date-taken, -" do
        photo1 = create :photos_photo, datetaken: Time.utc(2012)
        photo2 = create :photos_photo, datetaken: Time.utc(2013)
        expect(search(sorted_by: 'date-taken')).to eq([photo2, photo1])
      end

      it "sorts by date-taken, +" do
        photo1 = create :photos_photo, datetaken: Time.utc(2013)
        photo2 = create :photos_photo, datetaken: Time.utc(2012)
        expect(search(sorted_by: 'date-taken', direction: '+')).to eq([photo2, photo1])
      end

      it "limits page length" do
        photos = [1, 2].map { |day| create :photos_photo, lastupdate: Time.utc(2014, 1, day) }
        expect(search(sorted_by: 'last-updated', per_page: 1)).to eq([photos.last]) # note that direction = -
      end

      it "returns pages after 1" do
        photos = [1, 2].map { |day| create :photos_photo, lastupdate: Time.utc(2014, 1, day) }
        expect(search(sorted_by: 'last-updated', per_page: 1, page: 2)).to eq([photos[0]]) # note that direction = -
      end

    end

    context "when searching for activity" do
      let(:person) { create :person }

      it "returns a photo posted by the person the activity is done_by" do
        photo = create :photos_photo, person: person
        expect(search(did: 'activity', done_by: person.username)).to eq([photo])
      end

      it "ignores a photo posted by someone else" do
        create :photos_photo
        expect(search(did: 'activity', done_by: person.username)).to eq([])
      end

      it "returns a photo commented on by the person the activity is done_by" do
        photo = create :photos_photo
        create :comment, photo: photo, flickrid: person.flickrid, username: person.username
        expect(search(did: 'activity', done_by: person.username)).to eq([photo])
      end

      it "ignores a photo commented on by someone else" do
        commenter = create :person
        create :comment, flickrid: commenter.flickrid, username: commenter.username
        expect(search(did: 'activity', done_by: person.username)).to eq([])
      end

      it "searches in a date range" do
        photos = [1, 2, 4].map { |day| create :photos_photo, person: person, datetaken: Time.utc(2014, 1, day) }
        create :photos_photo, datetaken: Time.utc(2014, 1, 1)
        comments = [1, 3, 4].map do |day|
          create :comment, photo: create(:photos_photo), flickrid: person.flickrid, username: person.username,
            commented_at: Time.local(2014, 1, day).getutc
        end
        expect(search(did: 'activity', done_by: person.username, from_date: Time.utc(2014, 1, 2), to_date: Time.utc(2014, 1, 3))).
          to eq([comments[1].photo, photos[1]])
      end

      it "orders by activity date, descending" do
        photos = [1, 2].map { |day| create :photos_photo, person: person, datetaken: Time.local(2014, 1, day).getutc }
        expect(search(did: 'activity', done_by: person.username)).to eq(photos.reverse)
      end

      it "orders by activity date, ascending" do
        photos = [1, 2].map { |day| create :photos_photo, person: person, datetaken: Time.local(2014, 1, day).getutc }
        expect(search(did: 'activity', done_by: person.username, direction: '+')).to eq(photos)
      end

      it "limits page length" do
        photos = [1, 2].map { |day| create :photos_photo, person: person, datetaken: Time.utc(2014, 1, day) }
        expect(search(did: 'activity', done_by: person.username, per_page: 1)).to eq([photos.last]) # note that direction = -
      end

      it "returns pages after 1" do
        photos = [1, 2].map { |day| create :photos_photo, person: person, datetaken: Time.utc(2014, 1, day) }
        expect(search(did: 'activity', done_by: person.username, per_page: 1, page: 2)).to eq([photos[0]]) # note that direction = -
      end

    end

    def search(params = {})
      PhotosPhoto.search PhotosPhoto.search_defaults(params).merge(params)
    end

  end

  describe '#comments_that_match' do
    it "returns a comment that matches a word" do
      returns comment: "one", terms: [['one']]
    end

    it "is case-insensitive" do
      returns comment: "ONE", terms: [['one']]
    end

    it "ignores a comment that doesn't match a word" do
      ignores comment: "one", terms: [['two']]
    end

    it "ignores a comment that matches a word, but not on word boundaries" do
      ignores comment: "phones", terms: [['two']]
    end

    it "returns a comment that matches all of multiple words" do
      returns comment: "one two", terms: [['one', 'two']]
    end

    it "ignores a comment that does not match all of multiple words" do
      ignores comment: "one two", terms: [['one', 'three']]
    end

    it "returns a comment that matches any of multiple groups" do
      returns comment: "one", terms: [['one'], ['two']]
    end

    def returns(comment:, terms:)
      expect(comments_that_match(comment, terms).length).to eq(1)
    end

    def ignores(comment:, terms:)
      expect(comments_that_match(comment, terms)).to be_empty
    end

    def comments_that_match(comment, terms)
      create(:photos_photo).tap do |photo|
        create :comment, photo: photo, comment_text: comment
      end.
      comments_that_match(terms)
    end

  end

end
