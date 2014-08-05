describe PhotoPhotosSupport do

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
      photo1 = create :photo, person: person, dateadded: Time.utc(2010)
      photo2 = create :photo, person: person, dateadded: Time.utc(2011)
      Photo.all_sorted_and_paginated('username', '+', 1, 2).should == [ photo2, photo1 ]
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
      photo1 = create :photo, photo_1_options.merge({ person: person1 })
      person2 = create :person, person_2_options
      photo2 = create :photo, photo_2_options.merge({ person: person2 })
      Photo.all_sorted_and_paginated(sorted_by, '+', 1, 2).should == [ photo2, photo1 ]

    end

    it "paginates" do
      create_list :photo, 3
      Photo.all_sorted_and_paginated('username', '+', 1, 2).length.should == 2
    end

  end

  describe '.all_for_map' do
    let(:bounds) { Bounds.new 37.70571, 37.820904, -122.514381, -122.35714 }

    it "returns an unfound photo" do
      photo = build :photo, latitude: 37, longitude: -122
      stub(Photo).mapped(bounds, 2) { [ photo ] }
      stub(Photo).oldest { build :photo, dateadded: 1.day.ago }
      Photo.all_for_map(bounds, 1).should == {
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
      }
    end

    it "handles no photos" do
      stub(Photo).mapped(bounds, 2) { [] }
      stub(Photo).oldest { nil }
      Photo.all_for_map(bounds, 1).should == {
        partial: false,
        bounds: bounds,
        photos: []
      }
    end

    it "returns no more than a maximum number of photos" do
      photo = build :photo, latitude: 37, longitude: -122
      oldest_photo = build :photo, dateadded: 1.day.ago
      stub(Photo).mapped(bounds, 2) { [ photo, oldest_photo ] }
      stub(Photo).oldest { oldest_photo }
      Photo.all_for_map(bounds, 1).should == {
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
      }
    end

  end

  describe '.find_with_associations' do
    let(:photo_in) { create :photo }

    it "returns a revealed photo with all of its associated objects" do
      revelation = create :revelation, photo: photo_in
      photo_out = Photo.find_with_associations photo_in.id
      photo_out.person.should == photo_in.person
      photo_out.revelation.should == revelation
    end

    it "returns a guessed photo with all of its associated objects" do
      guess = create :guess, photo: photo_in
      photo_out = Photo.find_with_associations photo_in.id
      photo_out.person.should == photo_in.person
      photo_out.guesses.should == [ guess ]
      photo_out.guesses[0].person.should == guess.person
    end

  end

  describe '.unfound_or_unconfirmed' do
    %w(unfound unconfirmed).each do |game_status|
      it "returns #{game_status} photos" do
        photo = create :photo, game_status: game_status
        Photo.unfound_or_unconfirmed.should == [ photo ]
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        create :photo, game_status: game_status
        Photo.unfound_or_unconfirmed.should == []
      end
    end

  end

  describe '.search' do
    context "when searching for posts" do
      it "returns all photos" do
        create :photo
        Photo.search({}, 'last-updated', '-', 1).length.should == 1
      end

      context "when specifying done-by" do
        it "returns a photo posted by the person with the given username" do
          photo = create :photo
          Photo.search({ 'done-by' => photo.person.username }, 'last-updated', '-', 1).length.should == 1
        end

        it "ignores a photo posted by a person with a different username" do
          create :photo
          Photo.search({ 'done-by' => 'xyz' }, 'last-updated', '-', 1).length.should == 0
        end

      end

      context "when specifying text" do
        %i(title description).each do |attr|
          it "returns a photo whose #{attr} contains the given text" do
            create :photo, attr => 'one two three'
            photos_which_mention('two').length.should == 1
          end

          it "returns a photo whose #{attr} contains the given text in any case" do
            create :photo, attr => 'ONE TWO THREE'
            photos_which_mention('two').length.should == 1
          end

          it "returns a photo whose #{attr} contains the given text regardless of the case of the search term" do
            create :photo, attr => 'one two three'
            photos_which_mention('TWO').length.should == 1
          end

          it "ignores a photo whose #{attr} contains the given text, but not as a separate word" do
            create :photo, title: 'onetwothree'
            photos_which_mention('two').length.should == 0
          end

        end

        it "ignores a photo that has all the terms but in different attributes" do
          create :photo, title: 'one two three', description: 'four five six'
          photos_which_mention('two', 'five').length.should == 0
        end

        it "returns a photo with a tag that contains the given text" do
          create :tag, raw: 'one two three'
          photos_which_mention('two').length.should == 1
        end

        it "returns a photo with a tag that contains the given text in any case" do
          create :tag, raw: 'ONE TWO THREE'
          photos_which_mention('two').length.should == 1
        end

        it "returns a photo with a tag that contains the given text regardless of the case of the search term" do
          create :tag, raw: 'one two three'
          photos_which_mention('TWO').length.should == 1
        end

        it "returns a photo that has all the terms but in different tags" do
          photo = create :photo
          create :tag, photo: photo, raw: 'one two three'
          create :tag, photo: photo, raw: 'four five six'
          photos_which_mention('two', 'four').length.should == 1
        end

        it "ignores a photo with a tag that contains the given text, but not as a separate word" do
          create :tag, raw: 'onetwothree'
          photos_which_mention('two').length.should == 0
        end

        it "doesn't return all photos when a tag matches, just the one with the tag" do
          tag1 = create :tag, raw: 'one two three'
          create :tag
          photos_which_mention('two').should == [tag1.photo]
        end

        it "returns a photo with a comment that contains the given text" do
          create :comment, comment_text: 'one two three'
          photos_which_mention('two').length.should == 1
        end

        it "returns a photo with a comment that contains the given text in any case" do
          create :comment, comment_text: 'ONE TWO THREE'
          photos_which_mention('two').length.should == 1
        end

        it "returns a photo with a comment that contains the given text regardless of the case of the search term" do
          create :comment, comment_text: 'one two three'
          photos_which_mention('TWO').length.should == 1
        end

        it "ignores a photo that has all the terms but in different comments" do
          photo = create :photo
          create :comment, photo: photo, comment_text: 'one two three'
          create :comment, photo: photo, comment_text: 'four five six'
          photos_which_mention('two', 'four').length.should == 0
        end

        it "ignores a photo with a comment that contains the given text, but not as a separate word" do
          create :comment, comment_text: 'onetwothree'
          photos_which_mention('two').length.should == 0
        end

        it "doesn't return all photos when a comment matches, just the one with the comment" do
          comment1 = create :comment, comment_text: 'one two three'
          create :comment
          photos_which_mention('two').should == [comment1.photo]
        end

        it "searches for multiple terms" do
          create :photo, title: 'one two three four five'
          photos_which_mention('two', 'four').length.should == 1
        end

        it "ignores a photo that has only one of multiple terms" do
          create :photo, title: 'one two three'
          photos_which_mention('two', 'four').length.should == 0
        end

        it "searches for multiple groups in different attributes" do
          create :photo, title: 'one two three', description: 'four five six'
          Photo.search({ 'text' => [['two'], ['five']] }, 'last-updated', '-', 1).length.should == 1
        end

        it "ignores a photo none of whose title, description, tags or comments contains the given text" do
          create :photo
          photos_which_mention('Fort Point').length.should == 0
        end

        # It is a known bug that this method finds matches in HTML tag names and attributes. Fixing that would be hard.

        def photos_which_mention(*text)
          Photo.search({ 'text' => [text] }, 'last-updated', '-', 1)
        end

      end

      context "when specifying game_status" do
        it "returns a photo with the given status" do
          create :photo, game_status: 'found'
          Photo.search({ 'game-status' => %w(found) }, 'last-updated', '-', 1).length.should == 1
        end

        it "searches for photos with any of multiple statuses" do
          create :photo, game_status: 'found'
          create :photo, game_status: 'revealed'
          Photo.search({ 'game-status' => %w(found revealed) }, 'last-updated', '-', 1).length.should == 2
        end

        it "ignores a photo with a different status" do
          create :photo, game_status: 'found'
          Photo.search({ 'game-status' => %w(unfound) }, 'last-updated', '-', 1).length.should == 0
        end

      end

      it "searches in a date range" do
        photos = [1, 2, 3].map { |day| create :photo, dateadded: Time.local(2014, 1, day).getutc }
        Photo.search({ 'from-date' => '1/2/14', 'to-date' => '1/2/14' }, 'last-updated', '-', 1).should == [photos[1]]
      end

      it "searches by more than one criterion" do
        photo1 = create :photo, game_status: 'found'
        create :photo, person: photo1.person
        create :photo, game_status: 'found'
        Photo.search({ 'game-status' => 'found', 'done-by' => photo1.person.username }, 'last-updated', '-', 1).length.should == 1
      end

      it "sorts by last-updated, -" do
        photo1 = create :photo, lastupdate: Time.utc(2012)
        photo2 = create :photo, lastupdate: Time.utc(2013)
        Photo.search({}, 'last-updated', '-', 1).should == [photo2, photo1]
      end

      it "sorts by last-updated, +" do
        photo1 = create :photo, lastupdate: Time.utc(2013)
        photo2 = create :photo, lastupdate: Time.utc(2012)
        Photo.search({}, 'last-updated', '+', 1).should == [photo2, photo1]
      end

      it "sorts by date-added, -" do
        photo1 = create :photo, dateadded: Time.utc(2012)
        photo2 = create :photo, dateadded: Time.utc(2013)
        Photo.search({}, 'date-added', '-', 1).should == [photo2, photo1]
      end

      it "sorts by date-added, +" do
        photo1 = create :photo, dateadded: Time.utc(2013)
        photo2 = create :photo, dateadded: Time.utc(2012)
        Photo.search({}, 'date-added', '+', 1).should == [photo2, photo1]
      end

      it "paginates" do
        2.times { create :photo }
        Photo.search({}, 'last-updated', '-', 1, per_page: 1).length.should == 1
      end

    end

    context "when searching for activity" do
      let(:person) { create :person }

      it "returns a photo posted by the person the activity is done-by" do
        photo = create :photo, person: person
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '-', 1).should == [photo]
      end

      it "ignores a photo posted by someone else" do
        create :photo
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '-', 1).should == []
      end

      it "returns a photo commented on by the person the activity is done-by" do
        comment = create :comment, flickrid: person.flickrid, username: person.username
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '-', 1).should == [comment.photo]
      end

      it "ignores a photo commented on by someone else" do
        commenter = create :person
        create :comment, flickrid: commenter.flickrid, username: commenter.username
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '-', 1).should == []
      end

      it "searches in a date range" do
        photos = [1, 2, 4].map { |day| create :photo, person: person, dateadded: Time.local(2014, 1, day).getutc }
        photo = create :photo, dateadded: Time.local(2014, 1, 1).getutc
        comments = [1, 3, 4].map { |day| create :comment, flickrid: person.flickrid, username: person.username, commented_at: Time.local(2014, 1, day).getutc }
        Photo.search({ 'did' => 'activity', 'done-by' => person.username,
          'from-date' => '1/2/14', 'to-date' => '1/3/14' }, 'last-updated', '-', 1).should ==
          [comments[1].photo, photos[1]]
      end

      it "orders by activity date, descending" do
        photos = [1, 2].map { |day| create :photo, person: person, dateadded: Time.local(2014, 1, day).getutc }
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '-', 1).should == photos.reverse
      end

      it "orders by activity date, ascending" do
        photos = [1, 2].map { |day| create :photo, person: person, dateadded: Time.local(2014, 1, day).getutc }
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '+', 1).should == photos
      end

      it "paginates" do
        2.times { create :photo, person: person }
        Photo.search({ 'did' => 'activity', 'done-by' => person.username }, 'last-updated', '-', 1, per_page: 1).length.should == 1
      end

    end

  end

  describe '#human_tags' do
    let(:photo) { create :photo }

    it "returns non-machine tags sorted by id" do
      photo.tags.create! raw: 'Tag 2'
      photo.tags.create! raw: 'Tag 1'
      photo.human_tags.map(&:raw).should == ['Tag 2', 'Tag 1']
    end

    it "ignores machine tags" do
      photo.tags.create! raw: 'Machine tag 1', machine_tag: true
      photo.human_tags.should be_empty
    end

  end

  describe '#machine_tags' do
    let(:photo) { create :photo }

    it "returns machine tags sorted by id" do
      photo.tags.create! raw: 'Tag 2', machine_tag: true
      photo.tags.create! raw: 'Tag 1', machine_tag: true
      photo.machine_tags.map(&:raw).should == ['Tag 2', 'Tag 1']
    end

    it "ignores machine tags" do
      photo.tags.create! raw: 'Machine tag 1', machine_tag: false
      photo.machine_tags.should be_empty
    end

  end

  describe '#comments_that_match' do
    it "returns a comment that matches a word" do
      comment = create :comment, comment_text: "one"
      comment.photo.comments_that_match([['one']]).length.should == 1
    end

    it "is case-insensitive" do
      comment = create :comment, comment_text: "ONE"
      comment.photo.comments_that_match([['one']]).length.should == 1
    end

    it "ignores a comment that doesn't match a word" do
      comment = create :comment, comment_text: "one"
      comment.photo.comments_that_match([['two']]).length.should == 0
    end

    it "ignores a comment that matches a word, but not on word boundaries" do
      comment = create :comment, comment_text: "phones"
      comment.photo.comments_that_match([['one']]).length.should == 0
    end

    it "returns a comment that matches all of multiple words" do
      comment = create :comment, comment_text: "one two"
      comment.photo.comments_that_match([['one', 'two']]).length.should == 1
    end

    it "ignores a comment that does not match all of multiple words" do
      comment = create :comment, comment_text: "one two"
      comment.photo.comments_that_match([['one', 'three']]).length.should == 0
    end

    it "returns a comment that matches any of multiple groups" do
      comment = create :comment, comment_text: "one"
      comment.photo.comments_that_match([['one'], ['two']]).length.should == 1
    end

  end

end
