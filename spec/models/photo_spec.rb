describe Photo do
  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#dateadded' do
    it { should validate_presence_of :dateadded }
  end

  describe '#latitude' do
    it { should validate_numericality_of :latitude }
  end

  describe '#longitude' do
    it { should validate_numericality_of :longitude }
  end

  describe '#accuracy' do
    it { should validate_numericality_of :accuracy }
    it { should validate_non_negative_integer :accuracy }
  end

  describe '#lastupdate' do
    it { should validate_presence_of :lastupdate }
  end

  describe '#seen_at' do
    it { should validate_presence_of :seen_at }
  end

  describe '#game_status' do
    it { should validate_presence_of :game_status }
    it { should ensure_inclusion_of(:game_status).in_array %w(unfound unconfirmed found revealed) }
  end

  describe '#views' do
    it { should validate_presence_of :views }
    it { should validate_non_negative_integer :views }
  end

  describe '#faves' do
    it { should validate_presence_of :faves }
    it { should validate_non_negative_integer :faves }
  end

  describe '#other_user_comments' do
    it { should validate_presence_of :other_user_comments }
    it { should validate_non_negative_integer :other_user_comments }
  end

  describe '#member_comments' do
    it { should validate_presence_of :member_comments }
    it { should validate_non_negative_integer :member_comments }
  end

  describe '#member_questions' do
    it { should validate_presence_of :member_questions }
    it { should validate_non_negative_integer :member_questions }
  end

  describe '#destroy' do
    let(:photo) { create :photo }

    it "destroys the photo and its person" do
      photo.destroy
      Photo.any?.should be_falsy
      Person.any?.should be_falsy
    end

    it "leaves the person alone if they have another photo" do
      person = photo.person
      create :photo, person: person
      photo.destroy
      Photo.exists?(photo.id).should be_falsy
      Person.exists?(person.id).should be_truthy
    end

    it "leaves the person alone if they have a guess" do
      person = photo.person
      create :guess, person: person
      photo.destroy
      Photo.exists?(photo.id).should be_falsy
      Person.exists?(person.id).should be_truthy
    end

    it "destroys the photo's tags" do
      create :tag, photo: photo
      photo.destroy
      Tag.any?.should be_falsy
    end

    it "destroys the photo's comments" do
      create :comment, photo: photo
      photo.destroy
      Comment.any?.should be_falsy
    end

    it "destroys the photo's revelation" do
      create :revelation, photo: photo
      photo.destroy
      Revelation.any?.should be_falsy
    end

    it "destroys the photo's guesses" do
      create :guess, photo: photo
      photo.destroy
      Guess.any?.should be_falsy
    end

  end

  # Used by ScoreReportController

  describe '.count_between' do
    it 'counts all photos between the given dates' do
      create :photo, dateadded: Time.utc(2011, 1, 1, 0, 0, 1)
      Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == 1
    end

    it 'ignores photos made on or before the from date' do
      create :photo, dateadded: Time.utc(2011)
      Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == 0
    end

    it 'ignores photos made after the to date' do
      create :photo, dateadded: Time.utc(2011, 1, 1, 0, 0, 2)
      Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == 0
    end

  end

  describe '.unfound_or_unconfirmed_count_before' do
    it "counts photos added on or before and not scored on or before the given date" do
      create :photo, dateadded: Time.utc(2011)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 1
    end

    it "includes photos guessed after the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, added_at: Time.utc(2011, 2)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 1
    end

    it "includes photos revealed after the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :revelation, photo: photo, added_at: Time.utc(2011, 2)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 1
    end

    it "ignores photos added after the given date" do
      create :photo, dateadded: Time.utc(2011, 2)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 0
    end

    it "ignores photos guessed on or before the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, added_at: Time.utc(2011)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 0
    end

    it "ignores photos revealed on or before the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :revelation, photo: photo, added_at: Time.utc(2011)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 0
    end

  end

  describe '.add_posts' do
    let(:person) { create :person }

    it "adds each person's posts as an attribute" do
      create :photo, person: person, dateadded: Time.utc(2010)
      Photo.add_posts [ person ], Time.utc(2011), :post_count
      person.post_count.should == 1
    end

    it "ignores posts made after the report date" do
      create :photo, person: person, dateadded: Time.utc(2011)
      Photo.add_posts [ person ], Time.utc(2010), :post_count
      person.post_count.should == 0
    end

  end

  # Used by PeopleController

  describe '.posted_or_guessed_by_and_mapped' do
    let(:bounds) { Bounds.new 36, 38, -123, -121 }

    it "returns photos posted by the person" do
      returns_post latitude: 37, longitude: -122, accuracy: 12
    end

    it "ignores other people's posts" do
      create :photo, latitude: 37, longitude: -122, accuracy: 12
      other_person = create :person
      Photo.posted_or_guessed_by_and_mapped(other_person.id, bounds, 1).should == []
    end

    it "returns photos guessed by the person" do
      photo = create :photo, latitude: 37, longitude: -122, accuracy: 12
      guess = create :guess, photo: photo
      Photo.posted_or_guessed_by_and_mapped(guess.person.id, bounds, 1).should == [ photo ]
    end

    it "ignores other people's guesses" do
      photo = create :photo, latitude: 37, longitude: -122, accuracy: 12
      create :guess, photo: photo
      other_person = create :person
      Photo.posted_or_guessed_by_and_mapped(other_person.id, bounds, 1).should == []
    end

    it "returns auto-mapped photos" do
      returns_post inferred_latitude: 37, inferred_longitude: -122
    end

    it "ignores unmapped photos" do
      ignores_post({})
    end

    it "ignores mapped photos with accuracy < 12" do
      ignores_post latitude: 37, longitude: -122, accuracy: 11
    end

    it "ignores mapped photos south of the minimum latitude" do
      ignores_post latitude: 35, longitude: -122, accuracy: 12
    end

    it "ignores mapped photos north of the maximum latitude" do
      ignores_post latitude: 39, longitude: -122, accuracy: 12
    end

    it "ignores mapped photos west of the minimum longitude" do
      ignores_post latitude: 37, longitude: -124, accuracy: 12
    end

    it "ignores mapped photos east of the maximum longitude" do
      ignores_post latitude: 37, longitude: -120, accuracy: 12
    end

    it "ignores auto-mapped photos south of the minimum latitude" do
      ignores_post inferred_latitude: 35, inferred_longitude: -122
    end

    it "ignores auto-mapped photos north of the maximum latitude" do
      ignores_post inferred_latitude: 39, inferred_longitude: -122
    end

    it "ignores auto-mapped photos west of the minimum longitude" do
      ignores_post inferred_latitude: 37, inferred_longitude: -124
    end

    it "ignores auto-mapped photos east of the maximum longitude" do
      ignores_post inferred_latitude: 37, inferred_longitude: -120
    end

    it "returns only the youngest n photos" do
      photo = create :photo, latitude: 37, longitude: -122, accuracy: 12
      create :photo, latitude: 37, longitude: -122, dateadded: 1.day.ago, accuracy: 12
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1).should == [ photo ]
    end

    def returns_post(attributes)
      photo = create :photo, attributes
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1).should == [ photo ]
    end

    def ignores_post(attributes)
      photo = create :photo, attributes
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, bounds, 1).should == []
    end

  end

  describe '#has_obsolete_tags?' do
    %w(found revealed).each do |game_status|
      it "returns true if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_truthy
      end
    end

    it "is case-insensitive" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'UNFOUNDINSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    %w(unfound unconfirmed).each do |game_status|
      it "returns false if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_falsy
      end
    end

    it "returns false if a found photo is tagged something else" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unseeninSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a found photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns true if a found photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

  end

  # Used by PhotosController

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
      3.times { create :photo }
      Photo.all_sorted_and_paginated('username', '+', 1, 2).length.should == 2
    end

  end

  describe '.mapped' do
    let(:bounds) { Bounds.new 0, 2, 3, 5 }

    it "returns photos" do
      photo = create :photo, latitude: 1, longitude: 4, accuracy: 12
      Photo.mapped(bounds, 1).should == [ photo ]
    end

    it "returns auto-mapped photos" do
      photo = create :photo, inferred_latitude: 1, inferred_longitude: 4, accuracy: 12
      Photo.mapped(bounds, 1).should == [ photo ]
    end

    it "ignores unmapped photos" do
      create :photo
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores mapped photos with accuracy < 12" do
      create :photo, latitude: 1, longitude: 4, accuracy: 11
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores mapped photos south of the minimum latitude" do
      create :photo, latitude: -1, longitude: 4, accuracy: 12
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores mapped photos north of the maximum latitude" do
      create :photo, latitude: 3, longitude: 4, accuracy: 12
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores mapped photos west of the minimum longitude" do
      create :photo, latitude: 1, longitude: 2, accuracy: 12
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores mapped photos east of the maximum longitude" do
      create :photo, latitude: 1, longitude: 6, accuracy: 12
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores auto-mapped photos south of the minimum latitude" do
      create :photo, inferred_latitude: -1, inferred_longitude: 4
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores auto-mapped photos north of the maximum latitude" do
      create :photo, inferred_latitude: 3, inferred_longitude: 4
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores auto-mapped photos west of the minimum longitude" do
      create :photo, inferred_latitude: 1, inferred_longitude: 2
      Photo.mapped(bounds, 1).should == []
    end

    it "ignores auto-mapped photos east of the maximum longitude" do
      create :photo, inferred_latitude: 1, inferred_longitude: 6
      Photo.mapped(bounds, 1).should == []
    end

    it "returns only the youngest n photos" do
      photo = create :photo, latitude: 1, longitude: 4, accuracy: 12
      create :photo, latitude: 1, longitude: 4, accuracy: 12, dateadded: 1.day.ago
      Photo.mapped(bounds, 1).should == [ photo ]
    end

  end

  describe '.oldest' do
    it "returns the oldest photo" do
      create :photo
      photo = create :photo, dateadded: 1.day.ago
      Photo.oldest.should == photo
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
    it "returns all photos" do
      create :photo
      Photo.search({}, 'last-updated', '-', 1).length.should == 1
    end

    context "when specifying game_status" do
      it "returns a photo with the given status" do
        create :photo, game_status: 'found'
        Photo.search({ 'game_status' => %w(found) }, 'last-updated', '-', 1).length.should == 1
      end

      it "searches for photos with any of multiple statuses" do
        create :photo, game_status: 'found'
        create :photo, game_status: 'revealed'
        Photo.search({ 'game_status' => %w(found revealed) }, 'last-updated', '-', 1).length.should == 2
      end

      it "ignores a photo with a different status" do
        create :photo, game_status: 'found'
        Photo.search({ 'game_status' => %w(unfound) }, 'last-updated', '-', 1).length.should == 0
      end

    end

    context "when specifying posted_by" do
      it "returns a photo posted by the person with the given username" do
        photo = create :photo
        Photo.search({ 'posted_by' => photo.person.username }, 'last-updated', '-', 1).length.should == 1
      end

      it "ignores a photo posted by a person with a different username" do
        create :photo
        Photo.search({ 'posted_by' => 'xyz' }, 'last-updated', '-', 1).length.should == 0
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

    it "searches by more than one criterion" do
      photo1 = create :photo, game_status: 'found'
      create :photo, person: photo1.person
      create :photo, game_status: 'found'
      Photo.search({ 'game_status' => 'found', 'posted_by' => photo1.person.username }, 'last-updated', '-', 1).length.should == 1
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

  end

  describe '.comments_that_match' do
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

  describe '.human_tags' do
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

  describe '.machine_tags' do
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

  # Used by Admin::RootController

  describe '.unfound_or_unconfirmed_count' do
    %w(unfound unconfirmed).each do |game_status|
      it "counts #{game_status} photos" do
        create :photo, game_status: game_status
        Photo.unfound_or_unconfirmed_count.should == 1
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        create :photo, game_status: game_status
        Photo.unfound_or_unconfirmed_count.should == 0
      end
    end

  end

  describe '.update_statistics' do
    describe "when updating other user comments" do
      it "counts comments" do
        comment = create :comment
        Photo.update_statistics
        comment.photo.reload
        comment.photo.other_user_comments.should == 1
      end

      it "ignores comments by the poster" do
        photo = create :photo
        create :comment, photo: photo, flickrid: photo.person.flickrid, username: photo.person.username
        Photo.update_statistics
        photo.reload
        photo.other_user_comments.should == 0
      end

      it "handles photos which go from nonzero to zero comments" do
        photo = create :photo, other_user_comments: 1
        Photo.update_statistics
        photo.reload
        photo.other_user_comments.should == 0
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
        guess.photo.member_comments.should == 1
      end

      it 'ignores comments by the poster' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 0
      end

      it 'ignores comments by non-members' do
        guess = create :guess
        create :comment, photo: guess.photo
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 0
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
        guess.photo.member_comments.should == 2
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
        guess.photo.member_comments.should == 1
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = create :photo, member_comments: 1
        create :guess, photo: photo
        Photo.update_statistics
        photo.reload
        photo.member_comments.should == 0
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
        guess.photo.member_questions.should == 1
      end

      it 'ignores questions by the poster' do
        guess = create :guess
        create :comment, photo: guess.photo,
          flickrid: guess.photo.person.flickrid, username: guess.photo.person.username,
          comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 0
      end

      it 'ignores questions by non-members' do
        guess = create :guess
        create :comment, photo: guess.photo, comment_text: '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 0
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
        guess.photo.member_questions.should == 2
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
        guess.photo.member_questions.should == 1
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = create :photo, member_questions: 1
        create :guess, photo: photo
        Photo.update_statistics
        photo.reload
        photo.member_questions.should == 0
      end

    end

  end

  describe '#infer_geocodes' do
    let(:parser) do
      street_names = %w{ 26TH VALENCIA }
      stub(Stcline).multiword_street_names { street_names }
      parser = Object.new
      stub(LocationParser).new(street_names) { parser }
      parser
    end

    let(:factory) { RGeo::Cartesian.preferred_factory }

    it "infers each guessed photo's lat+long from its guess" do
      answer = create :guess, comment_text: 'A parseable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(parser).parse(answer.comment_text) { [ location ] }
      stub(Stintersection).geocode(location) { factory.point(-122, 37) }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == BigDecimal.new('37.0')
      answer.photo.inferred_longitude.should == BigDecimal.new('-122.0')

    end

    it "infers each revealed photo's lat+long from its revelation" do
      answer = create :revelation, comment_text: 'A parseable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(parser).parse(answer.comment_text) { [ location ] }
      stub(Stintersection).geocode(location) { factory.point(-122, 37) }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == BigDecimal.new('37.0')
      answer.photo.inferred_longitude.should == BigDecimal.new('-122.0')

    end

    it "removes an existing inferred geocode if the comment can't be parsed" do
      photo = create :photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'An unparseable comment'
      stub(parser).parse(answer.comment_text) { [] }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == nil
      answer.photo.inferred_longitude.should == nil

    end

    it "removes an existing inferred geocode if the location can't be geocoded" do
      photo = create :photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'A parseable but not geocodable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(parser).parse(answer.comment_text) { [ location ] }
      stub(Stintersection).geocode(location) { nil }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == nil
      answer.photo.inferred_longitude.should == nil

    end

    it "removes an existing inferred geocode if the comment has multiple geocodable locations" do
      photo = create :photo, inferred_latitude: 37, inferred_longitude: -122
      answer = create :guess, photo: photo, comment_text: 'A comment with multiple gecodable locations'
      location1 = Intersection.new '25th and Valencia', '25th', nil, 'Valencia', nil
      location2 = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(parser).parse(answer.comment_text) { [ location1, location2 ] }
      stub(Stintersection).geocode(location1) { factory.point(37, -122) }
      stub(Stintersection).geocode(location2) { factory.point(38, -122) }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == nil
      answer.photo.inferred_longitude.should == nil

    end

  end

  # Used by Admin::PhotosController

  describe '.inaccessible' do
    before do
      create :flickr_update, created_at: Time.utc(2011)
    end

    it "lists photos not seen since the last update" do
      photo = create :photo, seen_at: Time.utc(2010)
      Photo.inaccessible.should == [ photo ]
    end

    it "includes unconfirmed photos" do
      photo = create :photo, seen_at: Time.utc(2010), game_status: 'unconfirmed'
      Photo.inaccessible.should == [ photo ]
    end

    it "ignores photos seen since the last update" do
      create :photo, seen_at: Time.utc(2011)
      Photo.inaccessible.should == []
    end

    it "ignores statuses other than unfound and unconfirmed" do
      create :photo, seen_at: Time.utc(2010), game_status: 'found'
      Photo.inaccessible.should == []
    end

  end

  describe '.multipoint' do
    it 'returns photos for which more than one person got a point' do
      photo = create :photo
      create :guess, photo: photo
      create :guess, photo: photo
      Photo.multipoint.should == [ photo ]
    end

    it 'ignores photos for which only one person got a point' do
      create :guess
      Photo.multipoint.should == []
    end

  end

  describe '#ready_to_score?' do
    %w(unfound unconfirmed).each do |game_status|
      %w(foundinSF revealedinSF).each do |raw|
        it "returns true if the photo is #{game_status} and has a #{raw} tag" do
          photo = create :photo, game_status: game_status
          create :tag, photo: photo, raw: raw
          photo.ready_to_score?.should be_truthy
        end
      end
    end

    it "ignores tag case" do
      photo = create :photo, game_status: 'unfound'
      create :tag, photo: photo, raw: 'FOUNDINSF'
      photo.ready_to_score?.should be_truthy
    end

    it "returns false if the photo is neither unfound nor unconfirmed" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.ready_to_score?.should be_falsy
    end

    it "returns false if the photo does not have a foundinSF or revealedinSF tag" do
      photo = create :photo, game_status: 'unfound'
      create :tag, photo: photo, raw: 'unfoundinSF'
      photo.ready_to_score?.should be_falsy
    end

  end

  describe '#game_status_tags' do
    let(:photo) { create :photo }

    it "returns the photo's game status tags" do
      %w(unfoundinSF foundinSF revealedinSF).each do |raw|
        create :tag, photo: photo, raw: raw
      end
      photo.game_status_tags.map(&:raw).should == %w(unfoundinSF foundinSF revealedinSF)
    end

    it "is case-insensitive" do
      %w(UNFOUNDINSF FOUNDINSF REVEALEDINSF).each do |raw|
        create :tag, photo: photo, raw: raw
      end
      photo.game_status_tags.map(&:raw).should == %w(UNFOUNDINSF FOUNDINSF REVEALEDINSF)
    end

    it "ignores non-game-status tags" do
      create :tag, photo: photo
      photo.game_status_tags.should be_empty
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

  describe '.change_game_status' do
    let(:photo) { create :photo }

    it "changes the photo's status" do
      Photo.change_game_status photo.id, 'unconfirmed'
      photo.reload
      photo.game_status.should == 'unconfirmed'
    end

    it 'deletes existing guesses' do
      create :guess, photo: photo
      Photo.change_game_status photo.id, 'unconfirmed'
      Guess.count.should == 0
    end

    it 'deletes existing revelations' do
      create :revelation, photo: photo
      Photo.change_game_status photo.id, 'unconfirmed'
      Revelation.count.should == 0
    end

  end

  describe '.add_entered_answer' do
    let(:now) { Time.utc 2010 }
    let(:photo) { create :photo }

    context 'when adding a revelation' do
      it 'needs a non-empty comment text' do
        lambda { Photo.add_entered_answer photo.id, photo.person.username, '' }.should raise_error ArgumentError
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
        revelation.photo.game_status.should == 'revealed'
        revelation.comment_text.should == comment_text
        revelation.commented_at.should == now
        revelation.added_at.should == now
      end

      it 'deletes an existing guess' do
        create :guess, photo: photo
        Photo.add_entered_answer photo.id, photo.person.username, 'comment text'
        Guess.any?.should be_falsy
      end

    end

    context 'when adding a guess' do
      it 'adds a guess and updates the guesser if necessary' do
        guesser = create :person
        set_time
        stub_person_request
        Photo.add_entered_answer photo.id, guesser.username, 'comment text'

        photo.reload
        photo.guesses.length.should == 1
        guess = photo.guesses.first
        guess.person.should == guesser
        guess.comment_text.should == 'comment text'
        guess.commented_at.should == now
        guess.added_at.should == now
        guess.photo.game_status.should == 'found'

        guesser.reload
        guesser.username.should == 'username_from_request'
        guesser.pathalias.should == 'pathalias_from_request'

      end

      it 'creates the guesser if necessary' do
        comment = create :comment
        set_time
        stub_person_request
        Photo.add_entered_answer photo.id, comment.username, 'comment text'
        #noinspection RubyArgCount
        guess = Guess.includes(:person).find_by_photo_id photo
        guess.person.flickrid.should == comment.flickrid
        guess.person.username.should == 'username_from_request'
        guess.person.pathalias.should == 'pathalias_from_request'
      end

      it "leaves alone an existing guess by the same guesser" do
        old_guess = create :guess, photo: photo
        set_time
        stub_person_request
        Photo.add_entered_answer photo.id, old_guess.person.username, 'new comment text'

        guesses = photo.reload.guesses
        guesses.length.should == 2
        guesses.all? { |guess| guess.photo == photo }.should be_truthy
        guesses.all? { |guess| guess.person == old_guess.person }.should be_truthy
        guesses.map(&:comment_text).should =~ [old_guess.comment_text, 'new comment text']

      end

      it 'deletes an existing revelation' do
        create :revelation, photo: photo
        guesser = create :person
        stub_person_request
        Photo.add_entered_answer photo.id, guesser.username, 'comment text'
        Revelation.any?.should be_falsy
      end

      it "blows up if an unknown username is specified" do
        lambda { Photo.add_entered_answer photo.id, 'unknown_username', 'comment text' }.should raise_error Photo::AddAnswerError
      end

      def stub_person_request
        # noinspection RubyArgCount
        stub(FlickrService.instance).people_get_info { {
          'person' => [ {
            'username' => [ 'username_from_request' ],
            'photosurl' => [ 'https://www.flickr.com/photos/pathalias_from_request/' ]
          } ]
        } }
      end

    end

    # Specs of add_entered_answer call this immediately before calling add_selected_answer so
    # that it doesn't affect test objects' date attributes and assertions on those attributes don't pass by accident
    def set_time
      # noinspection RubyArgCount
      stub(Time).now { now }
    end

  end

  # Miscellaneous instance methods

  describe '#years_old' do
    it "returns 0 for a photo posted moments ago" do
      create(:photo, dateadded: Time.now).years_old.should == 0
    end

    it "returns 1 for a photo posted moments + 1 year ago" do
      create(:photo, dateadded: Time.now - 1.years).years_old.should == 1
    end

  end

  describe '#star_for_age' do
    now = Time.now
    expected = { 0 => nil, 1 => :bronze, 2 => :silver, 3 => :gold }
    expected.keys.sort.each do |years_old|
      it "returns a #{expected[years_old]} star for a #{years_old}-year-old photo" do
        photo = Photo.new dateadded: now - years_old.years
        photo.star_for_age.should == expected[years_old]
      end
    end
  end

  describe '#time_elapsed' do
    it 'returns the age with a precision of seconds in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      stub(Time).now { Time.utc(2001, 2, 2, 1, 1, 1) }
      photo.time_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second'
    end
  end

  describe '#ymd_elapsed' do
    it 'returns the age with a precision of days in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      stub(Time).now { Time.utc(2001, 2, 2, 1, 1, 1) }
      photo.ymd_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day'
    end
  end

  describe '#star_for_comments' do
    expected = { 0 => nil, 20 => :silver, 30 => :gold }
    expected.keys.sort.each do |other_user_comments|
      it "returns a #{expected[other_user_comments]} star for a photo with #{other_user_comments} comments" do
        photo = Photo.new other_user_comments: other_user_comments
        photo.star_for_comments.should == expected[other_user_comments]
      end
    end
  end

  describe '#star_for_views' do
    expected = { 0 => nil, 300 => :bronze, 1000 => :silver, 3000 => :gold }
    expected.keys.sort.each do |views|
      it "returns a #{expected[views]} star for a photo with #{views} views" do
        photo = Photo.new views: views
        photo.star_for_views.should == expected[views]
      end
    end
  end

  describe '#star_for_faves' do
    expected = { 0 => nil, 10 => :bronze, 30 => :silver, 100 => :gold }
    expected.keys.sort.each do |faves|
      it "returns a #{expected[faves]} star for a photo with #{faves} faves" do
        photo = Photo.new faves: faves
        photo.star_for_faves.should == expected[faves]
      end
    end
  end

  describe '#mapped' do
    it "returns false if the photo is not mapped" do
      build(:photo).mapped?.should == false
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 12).mapped?.should == true
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 11).mapped?.should == false
    end

    it "returns false even if the photo is auto-mapped" do
      build(:photo, inferred_latitude: 37, inferred_longitude: -122).mapped?.should == false
    end

  end

  describe '#mapped_or_automapped' do
    it "returns false if the photo is not mapped" do
      build(:photo).mapped_or_automapped?.should == false
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 12).mapped_or_automapped?.should == true
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      build(:photo, latitude: 37, longitude: -122, accuracy: 11).mapped_or_automapped?.should == false
    end

    it "returns true if the photo is auto-mapped" do
      build(:photo, inferred_latitude: 37, inferred_longitude: -122).mapped_or_automapped?.should == true
    end

  end

end
