require 'spec_helper'

describe Photo do
  def valid_attrs
    now = Time.now
    { :flickrid => 'flickrid',
      :dateadded => now, :lastupdate => now, :seen_at => now,
      :game_status => 'unfound',
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

    %w(unfound unconfirmed found revealed).each do |value|
      it "accepts '#{value}'" do
        #noinspection RubyResolve
        Photo.new(valid_attrs.merge({ :game_status => value })).should be_valid
      end
    end

    it "rejects other values" do
      #noinspection RubyResolve
      Photo.new(valid_attrs.merge({ :game_status => 'other' })).should_not be_valid
    end

  end

  describe '#views' do
    it { should validate_presence_of :views }
    it { should validate_non_negative_integer :views }
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

  # Used by ScoreReportController

  describe '.count_between' do
    it 'counts all photos between the given dates' do
      Photo.make :dateadded => Time.utc(2011, 1, 1, 0, 0, 1)
      Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == 1
    end

    it 'ignores photos made on or before the from date' do
      Photo.make :dateadded => Time.utc(2011)
      Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == 0
    end

    it 'ignores photos made after the to date' do
      Photo.make :dateadded => Time.utc(2011, 1, 1, 0, 0, 2)
      Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == 0
    end

  end

  describe '.unfound_or_unconfirmed_count_before' do
    it "counts photos added on or before and not scored on or before the given date" do
      Photo.make :dateadded => Time.utc(2011)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 1
    end

    it "includes photos guessed after the given date" do
      photo = Photo.make :dateadded => Time.utc(2011)
      Guess.make :photo => photo, :added_at => Time.utc(2011, 2)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 1
    end

    it "includes photos revealed after the given date" do
      photo = Photo.make :dateadded => Time.utc(2011)
      Revelation.make :photo => photo, :added_at => Time.utc(2011, 2)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 1
    end

    it "ignores photos added after the given date" do
      Photo.make :dateadded => Time.utc(2011, 2)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 0
    end

    it "ignores photos guessed on or before the given date" do
      photo = Photo.make :dateadded => Time.utc(2011)
      Guess.make :photo => photo, :added_at => Time.utc(2011)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 0
    end

    it "ignores photos revealed on or before the given date" do
      photo = Photo.make :dateadded => Time.utc(2011)
      Revelation.make :photo => photo, :added_at => Time.utc(2011)
      Photo.unfound_or_unconfirmed_count_before(Time.utc(2011)).should == 0
    end

  end

  describe '.add_posts' do
    it "adds each person's posts as an attribute" do
      person = Person.make
      Photo.make 1, :person => person, :dateadded => Time.utc(2010)
      Photo.add_posts [ person ], Time.utc(2011), :posts
      person[:posts].should == 1
    end

    it "ignores posts made after the report date" do
      person = Person.make
      Photo.make 1, :person => person, :dateadded => Time.utc(2011)
      Photo.add_posts [ person ], Time.utc(2010), :posts
      person[:posts].should == 0
    end

  end

  # Used by PeopleController

  describe '.first_by' do
    it "returns the poster's first post" do
      poster = Person.make
      Photo.make 'second', :person => poster, :dateadded => Time.utc(2001)
      first = Photo.make 'first', :person => poster, :dateadded => Time.utc(2000)
      Photo.first_by(poster).should == first
    end

    it "ignores other posters' photos" do
      Photo.make
      Photo.first_by(Person.make).should be_nil
    end

  end

  describe '.most_recent_by' do
    it "returns the poster's most recent post" do
      poster = Person.make
      Photo.make 'penultimate', :person => poster, :dateadded => Time.utc(2000)
      most_recent = Photo.make 'most_recent', :person => poster, :dateadded => Time.utc(2001)
      Photo.most_recent_by(poster).should == most_recent
    end

    it "ignores other posters' photos" do
      Photo.make
      Photo.most_recent_by(Person.make).should be_nil
    end

  end

  describe '.oldest_unfound' do
    it "returns the poster's oldest unfound" do
      poster = Person.make
      Photo.make 'second', :person => poster, :dateadded => Time.utc(2001)
      first = Photo.make 'first', :person => poster, :dateadded => Time.utc(2000)
      oldest_unfound = Photo.oldest_unfound poster
      oldest_unfound.should == first
      oldest_unfound[:place].should == 1
    end

    it "ignores other posters' photos" do
      Photo.make
      Photo.oldest_unfound(Person.make).should be_nil
    end

    it "considers unconfirmed photos" do
      photo = Photo.make :game_status => 'unconfirmed'
      Photo.oldest_unfound(photo.person).should == photo
    end

    it "ignores game statuses other than unfound and unconfirmed" do
      photo = Photo.make :game_status => 'found'
      Photo.oldest_unfound(photo.person).should be_nil
    end

    it "considers other posters' oldest unfounds when calculating place" do
      Photo.make 'oldest', :dateadded => Time.utc(2000)
      next_oldest = Photo.make 'next_oldest', :dateadded => Time.utc(2001)
      oldest_unfound = Photo.oldest_unfound next_oldest.person
      oldest_unfound.should == next_oldest
      oldest_unfound[:place].should == 2
    end

    it "considers unconfirmed photos when calculating place" do
      Photo.make 'oldest', :dateadded => Time.utc(2000), :game_status => 'unconfirmed'
      next_oldest = Photo.make 'next_oldest', :dateadded => Time.utc(2001)
      oldest_unfound = Photo.oldest_unfound next_oldest.person
      oldest_unfound.should == next_oldest
      oldest_unfound[:place].should == 2
    end

    it "ignores other posters' equally old unfounds when calculating place" do
      Photo.make 'oldest', :dateadded => Time.utc(2001)
      next_oldest = Photo.make 'next_oldest', :dateadded => Time.utc(2001)
      oldest_unfound = Photo.oldest_unfound next_oldest.person
      oldest_unfound.should == next_oldest
      oldest_unfound[:place].should == 1
    end

    it "handles a person with no photos" do
      Photo.oldest_unfound(Person.make).should be_nil
    end

  end

  describe '.most_commented' do
    it "returns the poster's most-commented photo" do
      poster = Person.make
      Photo.make 'second', :person => poster
      first = Photo.make 'first', :person => poster, :other_user_comments => 1
      Comment.make :photo => first
      most_commented = Photo.most_commented poster
      most_commented.should == first
      most_commented.other_user_comments.should == 1
      most_commented[:place].should == 1
    end

    it "counts comments" do
      poster = Person.make
      second = Photo.make 'second', :person => poster, :other_user_comments => 1
      Comment.make 21, :photo => second
      first = Photo.make 'first', :person => poster, :other_user_comments => 2
      Comment.make 11, :photo => first
      Comment.make 12, :photo => first
      most_commented = Photo.most_commented poster
      most_commented.should == first
      most_commented.other_user_comments.should == 2
      most_commented[:place].should == 1
    end

    it "ignores other posters' photos" do
      photo = Photo.make :other_user_comments => 1
      Comment.make :photo => photo
      Photo.most_commented(Person.make).should be_nil
    end

    it "considers other posters' photos when calculating place" do
      other_posters_photo = Photo.make 'other_posters', :other_user_comments => 2
      Comment.make 'o1', :photo => other_posters_photo
      Comment.make 'o2', :photo => other_posters_photo
      photo = Photo.make :other_user_comments => 1
      Comment.make :photo => photo
      Photo.most_commented(photo.person)[:place].should == 2
    end

    it "ignores other posters' equally commented photos when calculating place" do
      other_posters_photo = Photo.make 'other_posters', :other_user_comments => 1
      Comment.make 'other', :photo => other_posters_photo
      photo = Photo.make :other_user_comments => 1
      Comment.make :photo => photo
      Photo.most_commented(photo.person)[:place].should == 1
    end

    it "handles a person with no photos" do
      Photo.most_commented(Person.make).should be_nil
    end

  end

  describe '.most_viewed' do
    it "returns the poster's most-viewed photo" do
      poster = Person.make
      Photo.make 'second', :person => poster
      first = Photo.make 'first', :person => poster, :views => 1
      most_viewed = Photo.most_viewed poster
      most_viewed.should == first
      most_viewed[:place].should == 1
    end

    it "ignores other posters' photos" do
      Photo.make
      Photo.most_viewed(Person.make).should be_nil
    end

    it "considers other posters' photos when calculating place" do
      Photo.make 'other_posters', :views => 1
      photo = Photo.make
      Photo.most_viewed(photo.person)[:place].should == 2
    end

    it "ignores other posters' equally viewed photos when calculating place" do
      Photo.make 'other_posters'
      photo = Photo.make
      Photo.most_viewed(photo.person)[:place].should == 1
    end

    it "handles a person with no photos" do
      Photo.most_viewed(Person.make).should be_nil
    end

  end

  describe '.find_with_guesses' do
    it "returns a person's photos, with their guesses and the guesses' people" do
      guess = Guess.make
      photos = Photo.find_with_guesses guess.photo.person
      photos.should == [ guess.photo ]
      photos[0].guesses.should == [ guess ]
      photos[0].guesses[0].person.should == guess.person
    end
  end

  describe '.mapped_count' do
    it "counts mapped photos" do
      photo = Photo.make :accuracy => 12
      Photo.mapped_count(photo.person.id).should == 1
    end

    it "counts auto-mapped photos" do
      photo = Photo.make :inferred_latitude => 37
      Photo.mapped_count(photo.person.id).should == 1
    end

    it "ignores other people's photos" do
      Photo.make :accuracy => 12
      other_person = Person.make
      Photo.mapped_count(other_person.id).should == 0
    end

    it "ignores unmapped photos" do
      photo = Photo.make
      Photo.mapped_count(photo.person.id).should == 0
    end

    it "ignores photos mapped with an accuracy < 12" do
      photo = Photo.make :accuracy => 11
      Photo.mapped_count(photo.person.id).should == 0
    end

  end

  describe '.posted_or_guessed_by_and_mapped' do
    before do
      @bounds = Bounds.new(36, 38, -123, -121)
    end

    it "returns photos posted by the person" do
      returns_post :latitude => 37, :longitude => -122, :accuracy => 12
    end

    it "ignores other people's posts" do
      Photo.make :latitude => 37, :longitude => -122, :accuracy => 12
      other_person = Person.make
      Photo.posted_or_guessed_by_and_mapped(other_person.id, @bounds, 1).should == []
    end

    it "returns photos guessed by the person" do
      photo = Photo.make :latitude => 37, :longitude => -122, :accuracy => 12
      guess = Guess.make :photo => photo
      Photo.posted_or_guessed_by_and_mapped(guess.person.id, @bounds, 1).should == [ photo ]
    end

    it "ignores other people's guesses" do
      photo = Photo.make :latitude => 37, :longitude => -122, :accuracy => 12
      Guess.make :photo => photo
      other_person = Person.make
      Photo.posted_or_guessed_by_and_mapped(other_person.id, @bounds, 1).should == []
    end

    it "returns auto-mapped photos" do
      returns_post :inferred_latitude => 37, :inferred_longitude => -122
    end

    it "ignores unmapped photos" do
      ignores_post({})
    end

    it "ignores mapped photos with accuracy < 12" do
      ignores_post :latitude => 37, :longitude => -122, :accuracy => 11
    end

    it "ignores mapped photos south of the minimum latitude" do
      ignores_post :latitude => 35, :longitude => -122, :accuracy => 12
    end

    it "ignores mapped photos north of the maximum latitude" do
      ignores_post :latitude => 39, :longitude => -122, :accuracy => 12
    end

    it "ignores mapped photos west of the minimum longitude" do
      ignores_post :latitude => 37, :longitude => -124, :accuracy => 12
    end

    it "ignores mapped photos east of the maximum longitude" do
      ignores_post :latitude => 37, :longitude => -120, :accuracy => 12
    end

    it "ignores auto-mapped photos south of the minimum latitude" do
      ignores_post :inferred_latitude => 35, :inferred_longitude => -122
    end

    it "ignores auto-mapped photos north of the maximum latitude" do
      ignores_post :inferred_latitude => 39, :inferred_longitude => -122
    end

    it "ignores auto-mapped photos west of the minimum longitude" do
      ignores_post :inferred_latitude => 37, :inferred_longitude => -124
    end

    it "ignores auto-mapped photos east of the maximum longitude" do
      ignores_post :inferred_latitude => 37, :inferred_longitude => -120
    end

    it "returns only the youngest n photos" do
      photo = Photo.make 1, :latitude => 37, :longitude => -122, :accuracy => 12
      Photo.make 2, :latitude => 37, :longitude => -122, :dateadded => 1.day.ago, :accuracy => 12
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, @bounds, 1).should == [ photo ]
    end

    def returns_post(attributes)
      photo = Photo.make attributes
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, @bounds, 1).should == [ photo ]
    end

    def ignores_post(attributes)
      photo = Photo.make attributes
      Photo.posted_or_guessed_by_and_mapped(photo.person.id, @bounds, 1).should == []
    end

  end

  # Used by PhotosController

  describe '.all_sorted_and_paginated' do
    it 'returns photos sorted by username' do
      all_sorted_and_paginated_reverses_photos('username',
        { :username => 'z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2010) })
    end

    it 'ignores case' do
      all_sorted_and_paginated_reverses_photos('username',
        { :username => 'Z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by username, dateadded' do
      person = Person.make
      photo1 = Photo.make 1, :person => person, :dateadded => Time.utc(2010)
      photo2 = Photo.make 2, :person => person, :dateadded => Time.utc(2011)
      Photo.all_sorted_and_paginated('username', '+', 1, 2).should == [ photo2, photo1 ]
    end

    it 'returns photos sorted by dateadded' do
      all_sorted_and_paginated_reverses_photos('date-added',
        { :username => 'a' }, { :dateadded => Time.utc(2010) },
        { :username => 'z' }, { :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by dateadded, username' do
      all_sorted_and_paginated_reverses_photos('date-added',
        { :username => 'z' }, { :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by lastupdate' do
      all_sorted_and_paginated_reverses_photos('last-updated',
        { :username => 'a' }, { :lastupdate => Time.utc(2010) },
        { :username => 'z' }, { :lastupdate => Time.utc(2011) })
    end

    it 'returns photos sorted by lastupdate, username' do
      all_sorted_and_paginated_reverses_photos('last-updated',
        { :username => 'z' }, { :lastupdate => Time.utc(2011) },
        { :username => 'a' }, { :lastupdate => Time.utc(2011) })
    end

    it 'returns photos sorted by views' do
      all_sorted_and_paginated_reverses_photos('views',
        { :username => 'a' }, { :views => 0 },
        { :username => 'z' }, { :views => 1 })
    end

    it 'returns photos sorted by views, username' do
      all_sorted_and_paginated_reverses_photos('views',
        { :username => 'z' }, { :views => 0 },
        { :username => 'a' }, { :views => 0 })
    end

    it 'returns photos sorted by comments' do
      all_sorted_and_paginated_reverses_photos('comments',
        { :username => 'a' }, { :other_user_comments => 0 },
        { :username => 'z' }, { :other_user_comments => 1 })
    end

    it 'returns photos sorted by comments, username' do
      all_sorted_and_paginated_reverses_photos('comments',
        { :username => 'z' }, { :other_user_comments => 0 },
        { :username => 'a' }, { :other_user_comments => 0 })
    end

    it 'returns photos sorted by member_comments' do
      all_sorted_and_paginated_reverses_photos('member-comments',
        { :username => 'a' }, { :member_comments => 0, :dateadded => Time.utc(2011) },
        { :username => 'z' }, { :member_comments => 1, :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by member_comments, dateadded' do
      all_sorted_and_paginated_reverses_photos('member-comments',
        { :username => 'a' }, { :member_comments => 0, :dateadded => Time.utc(2010) },
        { :username => 'z' }, { :member_comments => 0, :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by member_comments, dateadded, username' do
      all_sorted_and_paginated_reverses_photos('member-comments',
        { :username => 'z' }, { :member_comments => 0, :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :member_comments => 0, :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by member_questions' do
      all_sorted_and_paginated_reverses_photos('member-questions',
        { :username => 'a' }, { :member_questions => 0, :dateadded => Time.utc(2011) },
        { :username => 'z' }, { :member_questions => 1, :dateadded => Time.utc(2010) })
    end

    it 'returns photos sorted by member_questions, dateadded' do
      all_sorted_and_paginated_reverses_photos('member-questions',
        { :username => 'a' }, { :member_questions => 0, :dateadded => Time.utc(2010) },
        { :username => 'z' }, { :member_questions => 0, :dateadded => Time.utc(2011) })
    end

    it 'returns photos sorted by member_questions, dateadded, username' do
      all_sorted_and_paginated_reverses_photos('member-questions',
        { :username => 'z' }, { :member_questions => 0, :dateadded => Time.utc(2011) },
        { :username => 'a' }, { :member_questions => 0, :dateadded => Time.utc(2011) })
    end

    def all_sorted_and_paginated_reverses_photos(sorted_by,
      person_1_options, photo_1_options, person_2_options, photo_2_options)

      person1 = Person.make 1, person_1_options
      photo1 = Photo.make 1, photo_1_options.merge({ :person => person1 })
      person2 = Person.make 2, person_2_options
      photo2 = Photo.make 2, photo_2_options.merge({ :person => person2 })
      Photo.all_sorted_and_paginated(sorted_by, '+', 1, 2).should == [ photo2, photo1 ]

    end

  end

  describe '.mapped' do
    before do
      @bounds = Bounds.new(0, 2, 3, 5)
    end

    it "returns photos" do
      photo = Photo.make :latitude => 1, :longitude => 4, :accuracy => 12
      Photo.mapped(@bounds, 1).should == [ photo ]
    end

    it "returns auto-mapped photos" do
      photo = Photo.make :inferred_latitude => 1, :inferred_longitude => 4, :accuracy => 12
      Photo.mapped(@bounds, 1).should == [ photo ]
    end

    it "ignores unmapped photos" do
      Photo.make
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores mapped photos with accuracy < 12" do
      Photo.make :latitude => 1, :longitude => 4, :accuracy => 11
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores mapped photos south of the minimum latitude" do
      Photo.make :latitude => -1, :longitude => 4, :accuracy => 12
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores mapped photos north of the maximum latitude" do
      Photo.make :latitude => 3, :longitude => 4, :accuracy => 12
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores mapped photos west of the minimum longitude" do
      Photo.make :latitude => 1, :longitude => 2, :accuracy => 12
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores mapped photos east of the maximum longitude" do
      Photo.make :latitude => 1, :longitude => 6, :accuracy => 12
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores auto-mapped photos south of the minimum latitude" do
      Photo.make :inferred_latitude => -1, :inferred_longitude => 4
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores auto-mapped photos north of the maximum latitude" do
      Photo.make :inferred_latitude => 3, :inferred_longitude => 4
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores auto-mapped photos west of the minimum longitude" do
      Photo.make :inferred_latitude => 1, :inferred_longitude => 2
      Photo.mapped(@bounds, 1).should == []
    end

    it "ignores auto-mapped photos east of the maximum longitude" do
      Photo.make :inferred_latitude => 1, :inferred_longitude => 6
      Photo.mapped(@bounds, 1).should == []
    end

    it "returns only the youngest n photos" do
      photo = Photo.make 1, :latitude => 1, :longitude => 4, :accuracy => 12
      Photo.make 2, :latitude => 1, :longitude => 4, :accuracy => 12, :dateadded => 1.day.ago
      Photo.mapped(@bounds, 1).should == [ photo ]
    end

  end

  describe '.oldest' do
    it "returns the oldest photo" do
      Photo.make 1
      photo = Photo.make 2, :dateadded => 1.day.ago
      Photo.oldest.should == photo
    end
  end

  describe '.unfound_or_unconfirmed' do
    %w(unfound unconfirmed).each do |game_status|
      it "returns #{game_status} photos" do
        photo = Photo.make :game_status => game_status
        Photo.unfound_or_unconfirmed.should == [ photo ]
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        Photo.make :game_status => game_status
        Photo.unfound_or_unconfirmed.should == []
      end
    end

  end

  # Used by WheresiesController

  describe '.most_viewed_in_year' do
    it 'lists photos' do
      photo = Photo.make :dateadded => Time.local(2010).getutc
      Photo.most_viewed_in(2010).should == [ photo ]
    end

    it 'sorts by views' do
      photo1 = Photo.make 1, :dateadded => Time.local(2010).getutc, :views => 0
      photo2 = Photo.make 2, :dateadded => Time.local(2010).getutc, :views => 1
      Photo.most_viewed_in(2010).should == [ photo2, photo1 ]
    end

    it 'ignores photos from before the year' do
      Photo.make :dateadded => Time.local(2009).getutc
      Photo.most_viewed_in(2010).should == []
    end

    it 'ignores photos from after the year' do
      Photo.make :dateadded => Time.local(2011).getutc
      Photo.most_viewed_in(2010).should == []
    end

  end

  describe '.most_commented_in_year' do
    it 'lists photos' do
      photo = Photo.make :dateadded => Time.local(2010).getutc
      Comment.make :photo => photo
      Photo.most_commented_in(2010).should == [ photo ]
    end

    it 'sorts by comment count' do
      photo1 = Photo.make 1, :dateadded => Time.local(2010).getutc
      Comment.make 11, :photo => photo1
      photo2 = Photo.make 2, :dateadded => Time.local(2010).getutc
      Comment.make 21, :photo => photo2
      Comment.make 22, :photo => photo2
      Photo.most_commented_in(2010).should == [ photo2, photo1 ]
    end

    it 'ignores photos from before the year' do
      photo = Photo.make :dateadded => Time.local(2009).getutc
      Comment.make :photo => photo
      Photo.most_commented_in(2010).should == []
    end

    it 'ignores photos from after the year' do
      photo = Photo.make :dateadded => Time.local(2011).getutc
      Comment.make :photo => photo
      Photo.most_commented_in(2010).should == []
    end

    it "ignores comments by the poster" do
      photo = Photo.make :dateadded => Time.local(2010).getutc
      Comment.make :photo => photo, :flickrid => photo.person.flickrid
      Photo.most_commented_in(2010).should == []
    end

  end

  # Used by Admin::RootController

  describe '.unfound_or_unconfirmed_count' do
    %w(unfound unconfirmed).each do |game_status|
      it "counts #{game_status} photos" do
        Photo.make :game_status => game_status
        Photo.unfound_or_unconfirmed_count.should == 1
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        Photo.make :game_status => game_status
        Photo.unfound_or_unconfirmed_count.should == 0
      end
    end

  end

  # Used by Admin::PhotosController

  describe '.update_all_from_flickr' do
    before do
      stub(FlickrCredentials).request('flickr.groups.pools.getPhotos', anything) { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'incoming_photo_flickrid',
            'owner' => 'incoming_person_flickrid',
            'ownername' => 'incoming_username',
            'pathalias' => 'incoming_pathalias',
            'farm' => '1',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '37.123456',
            'longitude' => '-122.654321',
            'accuracy' => '16',
            'lastupdate' => Time.utc(2011, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
    end

    it "gets the state of the group's photos from Flickr and stores it" do
      Photo.update_all_from_flickr.should == [ 1, 1, 1, 1 ]

      photos = Photo.all :include => :person
      photos.size.should == 1
      photo = photos[0]
      person = photo.person

      person.flickrid.should == 'incoming_person_flickrid'
      person.username.should == 'incoming_username'
      person.pathalias.should == 'incoming_pathalias'

      photo.flickrid.should == 'incoming_photo_flickrid'
      photo.farm.should == '1'
      photo.server.should == 'incoming_server'
      photo.secret.should == 'incoming_secret'
      photo.latitude.should == 37.123456
      photo.longitude.should == -122.654321
      photo.accuracy.should == 16
      photo.dateadded.should == Time.utc(2011)
      photo.lastupdate.should == Time.utc(2011, 1, 1, 1)
      photo.views.should == 50

    end

    it 'uses an existing person, and updates their information if it changed' do
      person_before = Person.make :flickrid => 'incoming_person_flickrid', :username => 'old_username', :pathalias => 'incoming_person_pathalias'
      Photo.update_all_from_flickr.should == [ 1, 0, 1, 1 ]
      people = Person.all
      people.size.should == 1
      person_after = people[0]
      person_after.id.should == person_before.id
      person_after.flickrid.should == person_before.flickrid
      person_after.username.should == 'incoming_username'
      person_after.pathalias.should == 'incoming_pathalias'
    end

    it 'uses an existing photo, and updates attributes that changed' do
      person = Person.make :flickrid => 'incoming_person_flickrid'
      photo_before = Photo.make \
        :person => person,
        :flickrid => 'incoming_photo_flickrid',
        :farm => '1',
        :server => 'old_server',
        :secret => 'old_secret',
        :latitude => 37.123456,
        :latitude => -122.654321,
        :accuracy => 16,
        :dateadded => Time.utc(2010),
        :lastupdate => Time.utc(2010, 1, 1, 1),
        :views => 40
      Photo.update_all_from_flickr.should == [ 0, 0, 1, 1 ]
      photos = Photo.all
      photos.size.should == 1
      photo_after = photos[0]
      photo_after.id.should == photo_before.id
      photo_after.flickrid.should == photo_before.flickrid
      photo_after.farm.should == '1'
      photo_after.server.should == 'incoming_server'
      photo_after.secret.should == 'incoming_secret'
      photo_after.latitude.should == 37.123456
      photo_after.longitude.should == -122.654321
      photo_after.accuracy.should == 16
      # Note that dateadded is not updated
      photo_after.dateadded.should == Time.utc(2010)
      photo_after.lastupdate.should == Time.utc(2011, 1, 1, 1)
      photo_after.views.should == 50
    end

    it "stores 0 latitude, longitude and accuracy as nil" do
      stub(FlickrCredentials).request('flickr.groups.pools.getPhotos', anything) { {
        'photos' => [ {
          'pages' => '1',
          'photo' =>  [ {
            'id' => 'incoming_photo_flickrid',
            'owner' => 'incoming_person_flickrid',
            'ownername' => 'incoming_username',
            'farm' => '0',
            'server' => 'incoming_server',
            'secret' => 'incoming_secret',
            'dateadded' => Time.utc(2011).to_i.to_s,
            'latitude' => '0',
            'longitude' => '0',
            'accuracy' => '0',
            'lastupdate' => Time.utc(2011, 1, 1, 1).to_i.to_s,
            'views' => '50'
          } ]
        } ]
      } }
      Photo.update_all_from_flickr.should == [ 1, 1, 1, 1 ]
      photos = Photo.all
      photos.size.should == 1
      photo = photos[0]
      photo.latitude.should be_nil
      photo.longitude.should be_nil
      photo.accuracy.should be_nil
    end

  end

  describe '.update_seen_at' do
    it 'updates seen_at' do
      photo = Photo.make :seen_at => Time.utc(2010)
      Photo.update_seen_at [ photo.flickrid ], Time.utc(2011)
      photo.reload
      photo.seen_at.should == Time.utc(2011)
    end
  end

  describe '.update_statistics' do
    describe "when updating other user comments" do
      it "counts comments" do
        comment = Comment.make
        Photo.update_statistics
        comment.photo.reload
        comment.photo.other_user_comments.should == 1
      end

      it "ignores comments by the poster" do
        photo = Photo.make
        Comment.make :photo => photo, :flickrid => photo.person.flickrid, :username => photo.person.username
        Photo.update_statistics
        photo.reload
        photo.other_user_comments.should == 0
      end

      it "handles photos which go from nonzero to zero comments" do
        photo = Photo.make :other_user_comments => 1
        Photo.update_statistics
        photo.reload
        photo.other_user_comments.should == 0
      end

    end

    describe "when updating member comments" do
      it 'counts comments on guessed photos' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 1
      end

      it 'ignores comments by the poster' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.photo.person.flickrid, :username => guess.photo.person.username
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 0
      end

      it 'ignores comments by non-members' do
        guess = Guess.make
        Comment.make :photo => guess.photo
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 0
      end

      it 'counts comments other than the guess' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at - 5
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 2
      end

      it 'ignores comments after the guess' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at + 5
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_comments.should == 1
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = Photo.make :member_comments => 1
        Guess.make :photo => photo
        Photo.update_statistics
        photo.reload
        photo.member_comments.should == 0
      end

    end

    describe "when updating member questions" do
      it 'counts questions on guessed photos' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at, :comment_text => '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 1
      end

      it 'ignores questions by the poster' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.photo.person.flickrid, :username => guess.photo.person.username,
          :comment_text => '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 0
      end

      it 'ignores questions by non-members' do
        guess = Guess.make
        Comment.make :photo => guess.photo, :comment_text => '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 0
      end

      it 'counts questions other than the guess' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at - 5, :comment_text => '?'
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at, :comment_text => '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 2
      end

      it 'ignores questions after the guess' do
        guess = Guess.make
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at, :comment_text => '?'
        Comment.make :photo => guess.photo,
          :flickrid => guess.person.flickrid, :username => guess.person.username,
          :commented_at => guess.commented_at + 5, :comment_text => '?'
        Photo.update_statistics
        guess.photo.reload
        guess.photo.member_questions.should == 1
      end

      # This shouldn't happen in the future, since if the poster deletes all of a photo's comments after it's guessed,
      # the Flickr update process will keep the old comments, but it did happen back when the Flickr update process
      # didn't work that way
      it "handles photos which go from nonzero to zero comments" do
        photo = Photo.make :member_questions => 1
        Guess.make :photo => photo
        Photo.update_statistics
        photo.reload
        photo.member_questions.should == 0
      end

    end

  end

  describe '.inaccessible' do
    it "lists photos not seen since the last update" do
      FlickrUpdate.make :created_at => Time.utc(2011)
      photo = Photo.make :seen_at => Time.utc(2010)
      Photo.inaccessible.should == [ photo ]
    end

    it "includes unconfirmed photos" do
      FlickrUpdate.make :created_at => Time.utc(2011)
      photo = Photo.make :seen_at => Time.utc(2010), :game_status => 'unconfirmed'
      Photo.inaccessible.should == [ photo ]
    end

    it "ignores photos seen since the last update" do
      FlickrUpdate.make :created_at => Time.utc(2011)
      Photo.make :seen_at => Time.utc(2011)
      Photo.inaccessible.should == []
    end

    it "ignores statuses other than unfound and unconfirmed" do
      FlickrUpdate.make :created_at => Time.utc(2011)
      Photo.make :seen_at => Time.utc(2010), :game_status => 'found'
      Photo.inaccessible.should == []
    end

  end

  describe '.multipoint' do
    it 'returns photos for which more than one person got a point' do
      photo = Photo.make
      Guess.make 1, :photo => photo
      Guess.make 2, :photo => photo
      Photo.multipoint.should == [ photo ]
    end

    it 'ignores photos for which only one person got a point' do
      Guess.make
      Photo.multipoint.should == []
    end

  end

  describe '#load_comments' do
    before do
      @photo = Photo.make
    end

    it 'loads comments from Flickr' do
      stub_request_to_return_one_comment
      is_the_comment_from_the_request @photo.load_comments
    end

    it 'deletes previous comments' do
      Comment.make 'previous', :photo => @photo
      stub_request_to_return_one_comment
      is_the_comment_from_the_request @photo.load_comments
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

    def is_the_comment_from_the_request(comments)
      comments.length.should == 1
      comment = comments[0]
      comment.flickrid.should == 'commenter_flickrid'
      comment.username.should == 'commenter_username'
      comment.comment_text.should == 'comment text'
    end

    it 'but not if the photo currently has no comments' do
      Comment.make 'previous', :photo => @photo
      empty_parsed_xml = {
        'comments' => [ {
        } ]
      }
      stub(FlickrCredentials).request { empty_parsed_xml }
      comments = @photo.load_comments
      comments.length.should == 1
      Comment.count.should == 1
    end

  end

  describe '.find_with_associations' do
    it "returns a revealed photo with all of its associated objects" do
      photo_in = Photo.make
      revelation = Revelation.make :photo => photo_in
      photo_out = Photo.find_with_associations photo_in.id
      photo_out.person.should == photo_in.person
      photo_out.revelation.should == revelation
    end

    it "returns a guessed photo with all of its associated objects" do
      photo_in = Photo.make
      guess = Guess.make :photo => photo_in
      photo_out = Photo.find_with_associations photo_in.id
      photo_out.person.should == photo_in.person
      photo_out.guesses.should == [ guess ]
      photo_out.guesses[0].person.should == guess.person
    end

  end

  describe '.change_game_status' do
    it "changes the photo's status" do
      photo = Photo.make
      Photo.change_game_status photo.id, 'unconfirmed'
      photo.reload
      photo.game_status.should == 'unconfirmed'
    end

    it 'deletes existing guesses' do
      photo = Photo.make
      guess = Guess.make :photo => photo
      Photo.change_game_status photo.id, 'unconfirmed'
      Guess.count.should == 0
      owner_does_not_exist guess
    end

    it 'deletes existing revelations' do
      photo = Photo.make
      Revelation.make :photo => photo
      Photo.change_game_status photo.id, 'unconfirmed'
      Revelation.count.should == 0
    end

  end

  describe '.destroy_photo_and_dependent_objects' do
    it 'destroys the photo and its person' do
      photo = Photo.make
      Photo.destroy_photo_and_dependent_objects photo.id
      Photo.count.should == 0
      owner_does_not_exist photo
    end

    it "destroys the photo's revelation" do
      revelation = Revelation.make
      Photo.destroy_photo_and_dependent_objects revelation.photo.id
      Revelation.count.should == 0
    end

    it "destroys the photo's guesses" do
      guess = Guess.make
      Photo.destroy_photo_and_dependent_objects guess.photo.id
      Guess.count.should == 0
      owner_does_not_exist guess
    end

  end

  describe '#destroy' do
    it 'destroys the photo and its person' do
      photo = Photo.make
      photo.destroy
      Photo.count.should == 0
      owner_does_not_exist photo
    end
  end

  describe '#infer_geocodes' do
    before do
      street_names = %w{ 26TH VALENCIA }
      stub(Stcline).multiword_street_names { street_names }
      @parser = Object.new
      stub(LocationParser).new(street_names) { @parser }

      @factory = RGeo::Cartesian.preferred_factory()

    end

    it "infers each guessed photo's lat+long from its guess" do
      answer = Guess.make :comment_text => 'A parseable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(@parser).parse(answer.comment_text) { [ location ] }
      stub(Stintersection).geocode(location) { @factory.point(-122, 37) }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == BigDecimal.new('37.0')
      answer.photo.inferred_longitude.should == BigDecimal.new('-122.0')

    end

    it "infers each revealed photo's lat+long from its revelation" do
      answer = Revelation.make :comment_text => 'A parseable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(@parser).parse(answer.comment_text) { [ location ] }
      stub(Stintersection).geocode(location) { @factory.point(-122, 37) }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == BigDecimal.new('37.0')
      answer.photo.inferred_longitude.should == BigDecimal.new('-122.0')

    end

    it "removes an existing inferred geocode if the comment can't be parsed" do
      photo = Photo.make :inferred_latitude => 37, :inferred_longitude => -122
      answer = Guess.make :photo => photo, :comment_text => 'An unparseable comment'
      stub(@parser).parse(answer.comment_text) { [] }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == nil
      answer.photo.inferred_longitude.should == nil

    end

    it "removes an existing inferred geocode if the location can't be geocoded" do
      photo = Photo.make :inferred_latitude => 37, :inferred_longitude => -122
      answer = Guess.make :photo => photo, :comment_text => 'A parseable but not geocodable comment'
      location = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(@parser).parse(answer.comment_text) { [ location ] }
      stub(Stintersection).geocode(location) { nil }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == nil
      answer.photo.inferred_longitude.should == nil

    end

    it "removes an existing inferred geocode if the comment has multiple geocodable locations" do
      photo = Photo.make :inferred_latitude => 37, :inferred_longitude => -122
      answer = Guess.make :photo => photo, :comment_text => 'A comment with multiple gecodable locations'
      location1 = Intersection.new '25th and Valencia', '25th', nil, 'Valencia', nil
      location2 = Intersection.new '26th and Valencia', '26th', nil, 'Valencia', nil
      stub(@parser).parse(answer.comment_text) { [ location1, location2 ] }
      stub(Stintersection).geocode(location1) { @factory.point(37, -122) }
      stub(Stintersection).geocode(location2) { @factory.point(38, -122) }
      Photo.infer_geocodes

      answer.photo.reload
      answer.photo.inferred_latitude.should == nil
      answer.photo.inferred_longitude.should == nil

    end

  end

  describe '#years_old' do
    it "returns 0 for a photo posted moments ago" do
      Photo.make(:dateadded => Time.now).years_old.should == 0
    end

    it "returns 1 for a photo posted moments + 1 year ago" do
      Photo.make(:dateadded => Time.now - 1.years).years_old.should == 1
    end

  end

  describe '#star_for_age' do
    now = Time.now
    expected = { 0 => nil, 1 => :bronze, 2 => :silver, 3 => :gold }
    expected.keys.sort.each do |years_old|
      it "returns a #{expected[years_old]} star for a #{years_old}-year-old photo" do
        photo = Photo.new :dateadded => now - years_old.years
        photo.star_for_age.should == expected[years_old]
      end
    end
  end

  describe '#time_elapsed' do
    it 'returns the age with a precision of seconds in English' do
      photo = Photo.new :dateadded => Time.utc(2000)
      stub(Time).now { Time.utc(2001, 2, 2, 1, 1, 1) }
      photo.time_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second';
    end
  end

  describe '#ymd_elapsed' do
    it 'returns the age with a precision of days in English' do
      photo = Photo.new :dateadded => Time.utc(2000)
      stub(Time).now { Time.utc(2001, 2, 2, 1, 1, 1) }
      photo.ymd_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day';
    end
  end

  describe '#star_for_comments' do
    expected = { 0 => nil, 20 => :silver, 30 => :gold }
    expected.keys.sort.each do |other_user_comments|
      it "returns a #{expected[other_user_comments]} star for a photo with #{other_user_comments} comments" do
        photo = Photo.new
        photo.other_user_comments = other_user_comments
        photo.star_for_comments.should == expected[other_user_comments]
      end
    end
  end

  describe '#star_for_views' do
    expected = { 0 => nil, 300 => :bronze, 1000 => :silver, 3000 => :gold }
    expected.keys.sort.each do |views|
      it "returns a #{expected[views]} star for a photo with #{views} views" do
        photo = Photo.new :views => views
        photo.star_for_views.should == expected[views]
      end
    end
  end

  describe '#mapped' do
    it "returns false if the photo is not mapped" do
      Photo.make.mapped?.should == false
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      Photo.make(:latitude => 37, :longitude => -122, :accuracy => 12).mapped?.should == true
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      Photo.make(:latitude => 37, :longitude => -122, :accuracy => 11).mapped?.should == false
    end

    it "returns false even if the photo is auto-mapped" do
      Photo.make(:inferred_latitude => 37, :inferred_longitude => -122).mapped?.should == false
    end

  end

  describe '#mapped_or_automapped' do
    it "returns false if the photo is not mapped" do
      Photo.make.mapped_or_automapped?.should == false
    end

    it "returns true if the photo is mapped at sufficient accuracy" do
      Photo.make(:latitude => 37, :longitude => -122, :accuracy => 12).mapped_or_automapped?.should == true
    end

    it "returns false if the photo is mapped at insufficient accuracy" do
      Photo.make(:latitude => 37, :longitude => -122, :accuracy => 11).mapped_or_automapped?.should == false
    end

    it "returns true if the photo is auto-mapped" do
      Photo.make(:inferred_latitude => 37, :inferred_longitude => -122).mapped_or_automapped?.should == true
    end

  end

end
