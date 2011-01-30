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

  describe '.update_seen_at' do
    it 'updates seen_at' do
      photo = Photo.create_for_test! :seen_at => Time.utc(2010)
      Photo.update_seen_at [ photo.flickrid ], Time.utc(2011)
      photo.reload
      photo.seen_at.should == Time.utc(2011)
    end
  end

  describe '.update_statistics' do
    it 'counts comments on guessed photos' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 1
    end

    it 'ignores comments by the poster' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.photo.person.flickrid, :username => guess.photo.person.username
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 0
    end

    it 'ignores comments by non-members' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 0
    end

    it 'counts comments other than the guess' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at - 5
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 2
    end

    it 'ignores comments after the guess' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at + 5
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_comments.should == 1
    end

    it 'counts questions on guessed photos' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 1
    end

    it 'ignores questions by the poster' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.photo.person.flickrid, :username => guess.photo.person.username,
        :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 0
    end

    it 'ignores questions by non-members' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 0
    end

    it 'counts questions other than the guess' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at - 5, :comment_text => '?'
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 2
    end

    it 'ignores questions after the guess' do
      guess = Guess.create_for_test!
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at, :comment_text => '?'
      Comment.create_for_test! :photo => guess.photo,
        :flickrid => guess.person.flickrid, :username => guess.person.username,
        :commented_at => guess.guessed_at + 5, :comment_text => '?'
      Photo.update_statistics
      guess.photo.reload
      guess.photo.member_questions.should == 1
    end

  end

  describe '.all_sorted_and_paginated' do
    it 'returns photos sorted by username' do
      all_sorted_and_paginated_should_reverse_photos('username',
        { :username => 'z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by username, dateadded' do
      person = Person.create_for_test!
      photo1 = Photo.create_for_test! :label => 1, :person => person, :dateadded => Time.utc(2010)
      photo2 = Photo.create_for_test! :label => 2, :person => person, :dateadded => Time.utc(2011)
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

      person1 = Person.create_for_test! person_1_options.merge({ :label => 1 })
      photo1 = Photo.create_for_test! photo_1_options.merge({ :label => 1, :person => person1 })
      person2 = Person.create_for_test! person_2_options.merge({ :label => 2 })
      photo2 = Photo.create_for_test! photo_2_options.merge({ :label => 2, :person => person2 })
      Photo.all_sorted_and_paginated(sorted_by, '+', 1, 2).should == [ photo2, photo1 ]

    end

  end

  describe '#unfound_or_unconfirmed_count' do
    %w(unfound unconfirmed).each do |game_status|
      it "counts #{game_status} photos" do
        Photo.create_for_test! :game_status => game_status
        Photo.unfound_or_unconfirmed_count.should == 1
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        Photo.create_for_test! :game_status => game_status
        Photo.unfound_or_unconfirmed_count.should == 0
      end
    end

  end

  describe '#unfound_or_unconfirmed' do
    %w(unfound unconfirmed).each do |game_status|
      it "returns #{game_status} photos" do
        photo = Photo.create_for_test! :game_status => game_status
        Photo.unfound_or_unconfirmed.should == [ photo ]
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        Photo.create_for_test! :game_status => game_status
        Photo.unfound_or_unconfirmed.should == []
      end
    end

  end

end
