require 'spec_helper'
require 'support/model_factory'

describe Photo do
  def valid_attrs
    now = Time.now
    { :flickrid => 'flickrid',
      :dateadded => now, 'mapped' => 'false',
      :lastupdate => now, :seen_at => now, :game_status => 'unfound',
      :views => 0, :member_comments => 0, :member_questions => 0 }
  end

  describe '#person' do
    it { should belong_to :person }
  end

  describe '#comments' do
    it { should have_many :comments }
  end

  describe '#guesses' do
    it { should have_many :guesses }
  end

  describe '#revelation' do
    it { should have_one :revelation }
  end

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#dateadded' do
    it { should validate_presence_of :dateadded }
  end

  describe '#mapped' do
    it { should validate_presence_of :mapped }

    %w(false true).each do |value|
      it "accepts '#{value}'" do
        Photo.new(valid_attrs.merge({ :mapped => value })).should be_valid
      end
    end

    it "rejects other values" do
      Photo.new(valid_attrs.merge({ :mapped => 'maybe' })).should_not be_valid
    end

  end

  describe '#lastupdate' do
    it { should validate_presence_of :lastupdate }
  end

  describe '#seen_at' do
    it { should validate_presence_of :seen_at }
  end

  describe '#game_status' do
    it { should validate_presence_of :game_status }

    %w(unfound unconfirmed found revealed).each do |value|
      it "accepts '#{value}'" do
        Photo.new(valid_attrs.merge({ :game_status => value })).should be_valid
      end
    end

    it "rejects other values" do
      Photo.new(valid_attrs.merge({ :game_status => 'other' })).should_not be_valid
    end

  end

  describe '#views' do
    it { should validate_presence_of :views }
    it { should validate_non_negative_integer :views }
  end

  describe '#member_comments' do
    it { should validate_presence_of :member_comments }
    it { should validate_non_negative_integer :member_comments }
  end

  describe '#member_questions' do
    it { should validate_presence_of :member_questions }
    it { should validate_non_negative_integer :member_questions }
  end

  # Used by PeopleController

  describe '.first_by' do
    it "returns the poster's first post" do
      poster = Person.make!
      Photo.make! :label => 'second', :person => poster, :dateadded => Time.utc(2001)
      first = Photo.make! :label => 'first', :person => poster, :dateadded => Time.utc(2000)
      Photo.first_by(poster).should == first
    end
  end

  describe '.most_recent_by' do
    it "returns the poster's most recent post" do
      poster = Person.make!
      Photo.make! :label => 'penultimate', :person => poster, :dateadded => Time.utc(2000)
      most_recent = Photo.make! :label => 'most_recent', :person => poster, :dateadded => Time.utc(2001)
      Photo.most_recent_by(poster).should == most_recent
    end
  end

  # Used by PhotosController

  describe '.all_sorted_and_paginated' do
    it 'returns photos sorted by username' do
      all_sorted_and_paginated_should_reverse_photos('username',
        { :username => 'z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2010) })
    end

    it 'ignores case' do
      all_sorted_and_paginated_should_reverse_photos('username',
        { :username => 'Z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by username, dateadded' do
      person = Person.make!
      photo1 = Photo.make! :label => 1, :person => person, :dateadded => Time.utc(2010)
      photo2 = Photo.make! :label => 2, :person => person, :dateadded => Time.utc(2011)
      Photo.all_sorted_and_paginated('username', '+', 1, 2).should == [ photo2, photo1 ]
    end

    it 'returns photos sorted by dateadded' do
      all_sorted_and_paginated_should_reverse_photos('date-added',
        { :username => 'a' }, { :dateadded => Time.utc(2010) },
        { :username => 'z' }, { :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by dateadded, username' do
      all_sorted_and_paginated_should_reverse_photos('date-added',
        { :username => 'z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by lastupdate' do
      all_sorted_and_paginated_should_reverse_photos('last-updated',
        { :username => 'a' }, { :lastupdate => Time.utc(2010) },
        { :username => 'z' }, { :lastupdate => Time.utc(2011) })
    end

    it 'returns photos sorted by lastupdate, username' do
      all_sorted_and_paginated_should_reverse_photos('last-updated',
        { :username => 'z' }, { :lastupdate => Time.utc(2011) },
        { :username => 'a' }, { :lastupdate => Time.utc(2011) })
    end

    it 'returns photos sorted by views' do
      all_sorted_and_paginated_should_reverse_photos('views',
        { :username => 'a' }, { :views => 0 },
        { :username => 'z' }, { :views => 1 })
    end

    it 'returns photos sorted by views, username' do
      all_sorted_and_paginated_should_reverse_photos('views',
        { :username => 'z' }, { :views => 0 },
        { :username => 'a' }, { :views => 0 })
    end

    it 'returns photos sorted by member_comments' do
      all_sorted_and_paginated_should_reverse_photos('member-comments',
        { :username => 'a' }, { :member_comments => 0, :dateadded => Time.utc(2011) },
        { :username => 'z' }, { :member_comments => 1, :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by member_comments, dateadded' do
      all_sorted_and_paginated_should_reverse_photos('member-comments',
        { :username => 'a' }, { :member_comments => 0, :dateadded => Time.utc(2010) },
        { :username => 'z' }, { :member_comments => 0, :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by member_comments, dateadded, username' do
      all_sorted_and_paginated_should_reverse_photos('member-comments',
        { :username => 'z' }, { :member_comments => 0, :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :member_comments => 0, :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by member_questions' do
      all_sorted_and_paginated_should_reverse_photos('member-questions',
        { :username => 'a' }, { :member_questions => 0, :dateadded => Time.utc(2011) },
        { :username => 'z' }, { :member_questions => 1, :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by member_questions, dateadded' do
      all_sorted_and_paginated_should_reverse_photos('member-questions',
        { :username => 'a' }, { :member_questions => 0, :dateadded => Time.utc(2010) },
        { :username => 'z' }, { :member_questions => 0, :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by member_questions, dateadded, username' do
      all_sorted_and_paginated_should_reverse_photos('member-questions',
        { :username => 'z' }, { :member_questions => 0, :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :member_questions => 0, :dateadded => Time.utc(2011) })
    end

    def all_sorted_and_paginated_should_reverse_photos(sorted_by,
      person_1_options, photo_1_options, person_2_options, photo_2_options)

      person1 = Person.make! person_1_options.merge({ :label => 1 })
      photo1 = Photo.make! photo_1_options.merge({ :label => 1, :person => person1 })
      person2 = Person.make! person_2_options.merge({ :label => 2 })
      photo2 = Photo.make! photo_2_options.merge({ :label => 2, :person => person2 })
      Photo.all_sorted_and_paginated(sorted_by, '+', 1, 2).should == [ photo2, photo1 ]

    end

  end

  describe '.unfound_or_unconfirmed' do
    %w(unfound unconfirmed).each do |game_status|
      it "returns #{game_status} photos" do
        photo = Photo.make! :game_status => game_status
        Photo.unfound_or_unconfirmed.should == [ photo ]
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        Photo.make! :game_status => game_status
        Photo.unfound_or_unconfirmed.should == []
      end
    end

  end

  # Used by WheresiesController

  describe '.most_viewed_in_2010' do
    it 'lists photos' do
      photo = Photo.make! :dateadded => Time.utc(2010)
      Photo.most_viewed_in_2010.should == [ photo ]
    end

    it 'sorts by views' do
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2010), :views => 0
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2010), :views => 1
      Photo.most_viewed_in_2010.should == [ photo2, photo1 ]
    end

    it 'ignores photos from before 2010' do
      Photo.make! :dateadded => Time.utc(2009)
      Photo.most_viewed_in_2010.should == []
    end

    it 'ignores photos from after 2010' do
      Photo.make! :dateadded => Time.utc(2011)
      Photo.most_viewed_in_2010.should == []
    end

  end

  describe '.most_commented_in_2010' do
    it 'lists photos' do
      photo = Photo.make! :dateadded => Time.utc(2010)
      Comment.make! :photo => photo
      Photo.most_commented_in_2010.should == [ photo ]
    end

    it 'sorts by comment count' do
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2010)
      Comment.make! :label => 11, :photo => photo1
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2010)
      Comment.make! :label => 21, :photo => photo2
      Comment.make! :label => 22, :photo => photo2
      Photo.most_commented_in_2010.should == [ photo2, photo1 ]
    end

    it 'ignores photos from before 2010' do
      photo = Photo.make! :dateadded => Time.utc(2009)
      Comment.make! :photo => photo
      Photo.most_commented_in_2010.should == []
    end

    it 'ignores photos from after 2010' do
      photo = Photo.make! :dateadded => Time.utc(2011)
      Comment.make! :photo => photo
      Photo.most_commented_in_2010.should == []
    end

  end

  # Used by Admin::RootController, Admin::GuessesController

  describe '.unfound_or_unconfirmed_count' do
    %w(unfound unconfirmed).each do |game_status|
      it "counts #{game_status} photos" do
        Photo.make! :game_status => game_status
        Photo.unfound_or_unconfirmed_count.should == 1
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        Photo.make! :game_status => game_status
        Photo.unfound_or_unconfirmed_count.should == 0
      end
    end

  end

  # Used by Admin::PhotosController

  describe '.update_all_from_flickr' do
    before do
      stub(FlickrCredentials).request('flickr.groups.getInfo') { {
        'group'=> [ {
          'members'=>['1492']
        } ]
      } }
      stub(FlickrCredentials).request('flickr.groups.pools.getPhotos', anything) { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'photo_flickrid',
            'owner' => 'person_flickrid',
            'ownername' => 'username',
            'farm' => '0',
            'server' => 'server',
            'secret' => 'secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '0',
            'longitude' => '0',
            'lastupdate' => Time.utc(2011, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
    end

    it "gets the state of the group's photos from Flickr and stores it" do
      Photo.update_all_from_flickr.should == [ 1, 1, 1, 1 ]
      #noinspection RailsParamDefResolve
      photos = Photo.all :include => :person
      photos.size.should == 1
      photo = photos[0]
      person = photo.person
      person.flickrid.should == 'person_flickrid'
      person.username.should == 'username'
      photo.flickrid.should == 'photo_flickrid'
      photo.farm.should == '0'
      photo.server.should == 'server'
      photo.secret.should == 'secret'
      photo.dateadded.should == Time.utc(2011)
      photo.mapped.should == 'false'
      photo.lastupdate.should == Time.utc(2011, 1, 1, 1)
      photo.views.should == 50
      flickr_update_should_have_been_created
    end

    it 'uses an existing person, and updates their username if it changed' do
      person_before = Person.make! :flickrid => 'person_flickrid', :username => 'old_username'
      Photo.update_all_from_flickr.should == [ 1, 0, 1, 1 ]
      people = Person.all
      people.size.should == 1
      person_after = people[0]
      person_after.id.should == person_before.id
      person_after.flickrid.should == person_before.flickrid
      person_after.username.should == 'username'
      flickr_update_should_have_been_created
    end

    it 'uses an existing photo, and updates attributes that changed' do
      # It should never happen that a photo's user's flickrid changes, so make
      # the existing user's flickrid the same as in the mocked response
      person = Person.make! :flickrid => 'person_flickrid'
      photo_before = Photo.make! \
        :person => person,
        :flickrid => 'photo_flickrid',
        :farm => '1',
        :secret => 'old_secret',
        :server => 'old_server',
        :dateadded => Time.utc(2010),
        :mapped => 'true',
        :lastupdate => Time.utc(2010, 1, 1, 1),
        :views => 40
      Photo.update_all_from_flickr.should == [ 0, 0, 1, 1 ]
      photos = Photo.all
      photos.size.should == 1
      photo_after = photos[0]
      photo_after.id.should == photo_before.id
      photo_after.flickrid.should == photo_before.flickrid
      photo_after.farm.should == '0'
      photo_after.secret.should == 'secret'
      photo_after.server.should == 'server'
      photo_after.dateadded.should == Time.utc(2011)
      photo_after.mapped.should == 'false'
      photo_after.lastupdate.should == Time.utc(2011, 1, 1, 1)
      photo_after.views.should == 50
      flickr_update_should_have_been_created
    end

    def flickr_update_should_have_been_created
      updates = FlickrUpdate.all
      updates.size.should == 1
      update = updates[0]
      update.member_count.should == 1492
      #noinspection RubyResolve
      update.completed_at.should_not be_nil
    end

  end

  describe '.update_seen_at' do
    it 'updates seen_at' do
      photo = Photo.make! :seen_at => Time.utc(2010)
      Photo.update_seen_at [ photo.flickrid ], Time.utc(2011)
      photo.reload
      photo.seen_at.should == Time.utc(2011)
    end
  end

  describe '.update_statistics' do
    it 'counts comments on guessed photos' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 1
    end

    it 'ignores comments by the poster' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.photo.person.flickrid, :username => guess.photo.person.username
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 0
    end

    it 'ignores comments by non-members' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 0
    end

    it 'counts comments other than the guess' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at - 5
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 2
    end

    it 'ignores comments after the guess' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at + 5
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 1
    end

    it 'counts questions on guessed photos' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 1
    end

    it 'ignores questions by the poster' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.photo.person.flickrid, :username => guess.photo.person.username,
        :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 0
    end

    it 'ignores questions by non-members' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 0
    end

    it 'counts questions other than the guess' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at - 5, :comment_text => '?'
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 2
    end

    it 'ignores questions after the guess' do
      guess = Guess.make!
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at, :comment_text => '?'
      Comment.make! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at + 5, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 1
    end

  end

  describe '.multipoint' do
    it 'returns photos for which more than one person got a point' do
      photo = Photo.make!
      Guess.make! :label => 1, :photo => photo
      Guess.make! :label => 2, :photo => photo
      Photo.multipoint.should == [ photo ]
    end

    it 'ignores photos for which only one person got a point' do
      Guess.make!
      Photo.multipoint.should == []
    end

  end

  describe '#load_comments' do
    before do
      @photo = Photo.make!
    end

    it 'loads comments from Flickr' do
      stub_request_to_return_one_comment
      should_be_the_comment_from_the_request @photo.load_comments
    end

    it 'deletes previous comments' do
      Comment.make! :label => 'previous', :photo => @photo
      stub_request_to_return_one_comment
      should_be_the_comment_from_the_request @photo.load_comments
    end

    def stub_request_to_return_one_comment
      parsed_xml_with_one_comment = {
        'comments' => [ {
          'comment' => [ {
            'author' => 'commenter_flickrid',
            'authorname' => 'commenter_username',
            'content' => 'comment text'
          } ]
        } ]
      }
      stub(FlickrCredentials).request { parsed_xml_with_one_comment }
    end

    def should_be_the_comment_from_the_request(comments)
      comments.length.should == 1
      comment = comments[0]
      comment.flickrid.should == 'commenter_flickrid'
      comment.username.should == 'commenter_username'
      comment.comment_text.should == 'comment text'
    end

    it 'but not if the photo currently has no comments' do
      Comment.make! :label => 'previous', :photo => @photo
      empty_parsed_xml = {
        'comments' => [ {
        } ]
      }
      stub(FlickrCredentials).request { empty_parsed_xml }
      comments = @photo.load_comments
      # TODO Dave what is the UI consequence of returning 0 comments even if they're still in the database?
      comments.length.should == 0
      Comment.count.should == 1
    end

  end

  describe '.change_game_status' do
    it "changes the photo's status" do
      photo = Photo.make!
      Photo.change_game_status photo.id, 'unconfirmed'
      photo.reload
      photo.game_status.should == 'unconfirmed'
    end

    it 'deletes existing guesses' do
      photo = Photo.make!
      guess = Guess.make! :photo => photo
      Photo.change_game_status photo.id, 'unconfirmed'
      Guess.count.should == 0
      owner_should_not_exist guess
    end

    it 'deletes existing revelations' do
      photo = Photo.make!
      Revelation.make! :photo => photo
      Photo.change_game_status photo.id, 'unconfirmed'
      Revelation.count.should == 0
    end

  end

  describe '.add_answer' do
    describe 'when adding a guess' do
      it 'adds a guess' do
        guesser = Person.make!
        comment = Comment.make! :flickrid => guesser.flickrid,
          :username => guesser.username, :commented_at => Time.utc(2011)
        Photo.add_answer comment.id, ''
        guess = Guess.find_by_photo_id comment.photo
        guess.person_id.should == guesser.id
        guess.guess_text.should == comment.comment_text
        guess.guessed_at.should == comment.commented_at
        guess.photo.reload
        guess.photo.game_status.should == 'found'
      end

      it 'creates the guesser if necessary' do
        comment = Comment.make!
        Photo.add_answer comment.id, ''
        guess = Guess.find_by_photo_id comment.photo, :include => :person
        guess.person.flickrid.should == comment.flickrid
        guess.person.username.should == comment.username
      end

      it 'gives the point to another user' do
        scorer = Person.make! :label => 'scorer'
        scorer_comment = Comment.make! :label => 'scorer',
          :flickrid => scorer.flickrid, :username => scorer.username
        answer_comment = Comment.make! :label => 'answer', :commented_at => Time.utc(2011)
        Photo.add_answer answer_comment.id, scorer_comment.username
        guess = Guess.find_by_photo_id answer_comment.photo, :include => :person
        guess.person.flickrid.should == scorer_comment.flickrid
        guess.person.username.should == scorer_comment.username
        guess.guess_text.should == answer_comment.comment_text
        guess.guessed_at.should == answer_comment.commented_at
        answer_comment.photo.reload
        answer_comment.photo.game_status.should == 'found'
      end

      it 'updates an existing guess' do
        old_guess = Guess.make!
        comment = Comment.make! :photo => old_guess.photo,
          :flickrid => old_guess.person.flickrid, :username => old_guess.person.username,
          :commented_at => Time.utc(2011)
        Photo.add_answer comment.id, ''
        new_guesses = Guess.find_all_by_photo_id comment.photo
        new_guesses.should == [ old_guess ]
        #new_guess = new_guesses[0]
        # Note that the following two values are different than those for old_guess
        # TODO Dave why doesn't this work?
        #new_guess.guess_text.should == comment.comment_text
        #new_guess.guessed_at.should == comment.commented_at
      end

      it 'deletes an existing revelation' do
        guesser = Person.make!
        comment = Comment.make! :flickrid => guesser.flickrid,
          :username => guesser.username, :commented_at => Time.utc(2011)
        Revelation.make! :photo => comment.photo
        Photo.add_answer comment.id, ''
        Revelation.count.should == 0
      end

    end

    describe 'when adding a revelation' do
      it 'adds a revelation' do
        photo = Photo.make!
        comment = Comment.make! :photo => photo, :flickrid => photo.person.flickrid,
          :username => photo.person.username, :commented_at => Time.utc(2011)
        Photo.add_answer comment.id, ''
        photo.reload
        photo.game_status.should == 'revealed'
        revelation = Revelation.find_by_photo_id comment.photo.id
        revelation.revelation_text.should == comment.comment_text
        revelation.revealed_at.should == comment.commented_at
      end

      it 'updates an existing revelation' do
        old_revelation = Revelation.make!
        comment = Comment.make! :photo => old_revelation.photo,
          :flickrid => old_revelation.photo.person.flickrid,
          :username => old_revelation.photo.person.username,
          :commented_at => Time.utc(2011)
        Photo.add_answer comment.id, ''
        new_revelations = Revelation.find_all_by_photo_id comment.photo
        new_revelations.should == [ old_revelation ]
        #new_revelation = new_revelations[0]
        # Note that the following two values are different than those for old_guess
        # TODO Dave why doesn't this work?
        #new_revelation.revelation_text.should == comment.comment_text
        #new_revelation.revealed_at.should == comment.commented_at
      end

      it 'deletes an existing guess' do
        photo = Photo.make!
        comment = Comment.make! :photo => photo, :flickrid => photo.person.flickrid,
          :username => photo.person.username, :commented_at => Time.utc(2011)
        guess = Guess.make! :photo => photo
        Photo.add_answer comment.id, ''
        Guess.count.should == 0
        owner_should_not_exist guess
      end

    end

  end

  describe '.remove_answer' do
    describe "when the commenter didn't post the photo" do
      it 'removes a guess' do
        photo = Photo.make! :game_status => 'found'
        guess = Guess.make! :photo => photo
        comment = Comment.make! :photo => photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :comment_text => guess.guess_text
        Photo.remove_answer comment.id
        photo.reload
        photo.game_status.should == 'unfound'
        Guess.count.should == 0
        owner_should_not_exist guess
      end

      it "leaves the photo found if there's another guess" do
        photo = Photo.make! :game_status => 'found'
        guess1 = Guess.make! :label => 1, :photo => photo
        comment1 = Comment.make! :label => 1, :photo => photo,
          :flickrid => guess1.person.flickrid, :username => guess1.person.username,
          :comment_text => guess1.guess_text
        guess2 = Guess.make! :label => 2, :photo => photo
        Comment.make! :label => 2, :photo => photo,
          :flickrid => guess2.person.flickrid, :username => guess2.person.username,
          :comment_text => guess2.guess_text
        Photo.remove_answer comment1.id
        photo.reload
        photo.game_status.should == 'found'
        Guess.all.should == [ guess2 ]
      end

      it "blows up if the commenter doesn't have a guess for this comment" do
        person = Person.make!
        comment = Comment.make! :flickrid => person.flickrid, :username => person.username
        lambda { Photo.remove_answer comment.id }.should \
          raise_error Photo::RemoveAnswerError, 'That comment has not been recorded as a guess.'
      end

    end

    describe 'when the commenter did post the photo' do
      it 'removes a revelation' do
        photo = Photo.make :game_status => 'revealed'
        revelation = Revelation.make! :photo => photo
        comment = Comment.make! :photo => photo,
          :flickrid => photo.person.flickrid, :username => photo.person.username,
          :comment_text => revelation.revelation_text
        Photo.remove_answer comment.id
        photo.reload
        photo.game_status.should == 'unfound'
        Revelation.count.should == 0
      end

      it "blows up if the commenter doesn't have a revelation for this comment" do
        person = Person.make!
        photo = Photo.make! :person => person
        comment = Comment.make! :photo => photo, :flickrid => person.flickrid, :username => person.username
        lambda { Photo.remove_answer comment.id }.should \
          raise_error Photo::RemoveAnswerError, 'That comment has not been recorded as a revelation.'
      end

    end

    it "blows up if the commenter isn't in the database" do
      comment = Comment.make!
      lambda { Photo.remove_answer comment.id }.should \
        raise_error Photo::RemoveAnswerError, 'That comment has not been recorded as a guess or revelation.'
    end

  end

  describe '.destroy_photo_and_dependent_objects' do
    it 'destroys the photo and its person' do
      photo = Photo.make!
      Photo.destroy_photo_and_dependent_objects photo.id
      Photo.count.should == 0
      owner_should_not_exist photo
    end

    it "destroys the photo's revelation" do
      revelation = Revelation.make!
      Photo.destroy_photo_and_dependent_objects revelation.photo.id
      Revelation.count.should == 0
    end

    it "destroys the photo's guesses" do
      guess = Guess.make!
      Photo.destroy_photo_and_dependent_objects guess.photo.id
      Guess.count.should == 0
      owner_should_not_exist guess
    end

  end

  describe '#destroy' do
    it 'destroys the photo and its person' do
      photo = Photo.make!
      photo.destroy
      Photo.count.should == 0
      owner_should_not_exist photo
    end
  end

  # Used by Admin::GuessesController

  describe '.count_since' do
    it 'counts photos' do
      update = FlickrUpdate.make! :created_at => Time.utc(2011)
      Photo.make! :dateadded => Time.utc(2011)
      Photo.count_since(update).should == 1
    end

    it 'ignores photos added before the last update' do
      update = FlickrUpdate.make! :created_at => Time.utc(2011)
      Photo.make! :dateadded => Time.utc(2010)
      Photo.count_since(update).should == 0
    end

  end

  describe '.add_posts' do
    it "adds each person's posts as an attribute" do
      person = Person.make!
      Photo.make! :label => 1, :person => person
      Photo.make! :label => 2, :person => person
      Photo.add_posts [ person ]
      person[:posts].should == 2
    end
  end

  # Used by specs which delete a photo or guess to assert that the owner had no
  # other photos or other guesses, so they should have been deleted too.
  # It would be nice to mock the method that deletes the owner, which handles
  # cases where the owner has a photo or other guess and shouldn't be deleted,
  # but doing so would be ugly.
  def owner_should_not_exist(owner)
    Person.exists?(owner.person.id).should == false
  end

end
