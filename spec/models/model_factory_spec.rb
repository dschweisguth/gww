require 'spec_helper'

describe ModelFactory do
  describe '#make' do
    before do
      @factory = Object.new
      #noinspection RubyResolve
      @factory.extend ModelFactory
    end

    it "handles no args" do
      mock(@factory).make_for_test :new, '', {}
      @factory.make
    end

    it "handles options" do
      mock(@factory).make_for_test :new, '', { :other_option => 'other_option' }
      @factory.make :other_option => 'other_option'
    end

    it "handles a label passed in as a string" do
      mock(@factory).make_for_test :new, 'xxx_', {}
      @factory.make 'xxx'
    end

    it "handles a label passed in as a string plus options" do
      mock(@factory).make_for_test :new, 'xxx_', { :other_option => 'other_option' }
      @factory.make 'xxx', :other_option => 'other_option'
    end

    it "creates, too" do
      mock(@factory).make_for_test :create, '', {}
      @factory.make!
    end

  end
end

describe FlickrUpdate do
  describe '.make' do
    it "makes one" do
      should_make_default_flickr_update :make
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database FlickrUpdate
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_flickr_update :make!
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make!
    end

    it "saves it in the database" do
      make_should_save_in_database! FlickrUpdate
    end

  end

  def should_make_default_flickr_update(method)
    update = FlickrUpdate.send method
    update.created_at.should_not be_nil
    update.member_count.should == 0
    update.completed_at.should be_nil
  end

  def should_make_flickr_update_with_custom_attributes(method)
    created_at = Time.utc(2011)
    completed_at = Time.utc(2011, 2)
    update = FlickrUpdate.send method,
      :created_at => created_at,
      :member_count => 1,
      :completed_at => completed_at
    update.created_at.should == created_at
    update.member_count.should == 1
    update.completed_at.should == completed_at
  end

end

describe Person do
  describe '.make' do
    it "makes one" do
      should_make_default_person :make
    end

    it "overrides defaults" do
      should_make_person_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_person :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database Person
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_person :make!
    end

    it "overrides_defaults" do
      should_make_person_with_custom_attributes :make!
    end

    it "labels it" do
      should_make_labeled_person :make!
    end

    it "saves it in the database" do
      make_should_save_in_database! Person
    end

  end

  def should_make_default_person(method)
    person = Person.send method
    person.flickrid.should == 'person_flickrid'
    person.username.should == 'username'
  end

  def should_make_person_with_custom_attributes(method)
    person = Person.send method,
      :flickrid => 'other_person_flickrid',
      :username => 'other_username'
    person.flickrid.should == 'other_person_flickrid'
    person.username.should == 'other_username'
  end

  def should_make_labeled_person(method)
    person = Person.send method, 'label'
    person.flickrid.should == 'label_person_flickrid'
    person.username.should == 'label_username'
  end

end

describe Photo do
  describe '.make' do
    it "makes one" do
      should_make_default_photo :make
    end

    it "overrides defaults" do
      should_make_photo_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_photo :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database Photo
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_photo :make!
    end

    it "overrides defaults" do
      should_make_photo_with_custom_attributes :make!
    end

    it "labels it" do
      should_make_labeled_photo :make!
    end

    it "saves it in the database" do
      make_should_save_in_database! Photo
    end

  end

  def should_make_default_photo(method)
    photo = Photo.send method
    photo.person.flickrid.should == 'poster_person_flickrid'
    photo.flickrid.should == 'photo_flickrid'
    photo.farm.should == '0'
    photo.server.should == 'server'
    photo.secret.should == 'secret'
    photo.dateadded.should_not be_nil
    photo.mapped.should == 'false'
    photo.lastupdate.should_not be_nil
    photo.seen_at.should_not be_nil
    photo.game_status.should == 'unfound'
    photo.views.should == 0
    photo.member_comments.should == 0
    photo.member_questions.should == 0
  end

  def should_make_photo_with_custom_attributes(method)
    person = Person.send method, 'other_poster'
    photo = Photo.send method,
      :person => person,
      :flickrid => 'other_photo_flickrid',
      :farm => '1',
      :server => 'other_server',
      :secret => 'other_secret',
      :dateadded => Time.utc(2010),
      :mapped => 'true',
      :lastupdate => Time.utc(2011),
      :seen_at => Time.utc(2012),
      :game_status => 'found',
      :views => 1,
      :member_comments => 1,
      :member_questions => 1
    photo.person.flickrid.should == 'other_poster_person_flickrid'
    photo.flickrid.should == 'other_photo_flickrid'
    photo.farm.should == '1'
    photo.server.should == 'other_server'
    photo.secret.should == 'other_secret'
    photo.dateadded.should == Time.utc(2010)
    photo.mapped.should == 'true'
    photo.lastupdate.should == Time.utc(2011)
    photo.seen_at.should == Time.utc(2012)
    photo.game_status.should == 'found'
    photo.views.should == 1
    photo.member_comments.should == 1
    photo.member_questions.should == 1
  end

  def should_make_labeled_photo(method)
    photo = Photo.send method, 'label'
    photo.person.flickrid.should == 'label_poster_person_flickrid'
    photo.flickrid.should == 'label_photo_flickrid'
  end

end

describe Comment do
  describe '.make' do
    it "makes one" do
      should_make_default_comment :make
    end

    it "overrides defaults" do
      should_make_comment_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_comment :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database Comment
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_comment :make!
    end

    it "overrides defaults" do
      should_make_comment_with_custom_attributes :make!
    end

    it "labels it" do
      should_make_labeled_comment :make!
    end

    it "saves it in the database" do
      make_should_save_in_database! Comment
    end

  end

  def should_make_default_comment(method)
    comment = Comment.send method
    comment.photo.flickrid.should == 'commented_photo_flickrid'
    comment.flickrid.should == 'commenter_flickrid'
    comment.username.should == 'commenter_username'
    comment.comment_text.should == 'comment text'
    comment.commented_at.should_not be_nil
  end

  def should_make_comment_with_custom_attributes(method)
    photo = Photo.send method, 'other_commented'
    comment = Comment.send method,
      :photo => photo,
      :flickrid => 'other_commenter_flickrid',
      :username => 'other_commenter_username',
      :comment_text => 'other comment text',
      :commented_at => Time.utc(2011)
    comment.photo.flickrid.should == 'other_commented_photo_flickrid'
    comment.flickrid.should == 'other_commenter_flickrid'
    comment.username.should == 'other_commenter_username'
    comment.comment_text.should == 'other comment text'
    comment.commented_at.should == Time.utc(2011)
  end

  def should_make_labeled_comment(method)
    comment = Comment.send method, 'label'
    comment.photo.flickrid.should == 'label_commented_photo_flickrid'
    comment.flickrid.should == 'label_commenter_flickrid'
    comment.username.should == 'label_commenter_username'
    comment.comment_text.should == 'label_comment text'
  end

end

describe Guess do
  describe '.make' do
    it "makes one" do
      should_make_default_guess :make
    end

    it "overrides defaults" do
      should_make_guess_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_guess :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database Guess
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_guess :make!
    end

    it "overrides defaults" do
      should_make_guess_with_custom_attributes :make!
    end

    it "labels it" do
      should_make_labeled_guess :make!
    end

    it "saves it in the database" do
      make_should_save_in_database! Guess
    end

  end

  def should_make_default_guess(method)
    guess = Guess.send method
    guess.photo.flickrid.should == 'guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'guesser_person_flickrid'
    guess.guess_text.should == 'guess text'
    guess.guessed_at.should_not be_nil
    guess.added_at.should_not be_nil
  end

  def should_make_guess_with_custom_attributes(method)
    photo = Photo.send method, 'other_guessed_photo'
    guesser = Person.send method, 'other_guesser'
    guess = Guess.send method,
      :photo => photo,
      :person => guesser,
      :guess_text => 'other guess text',
      :guessed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    guess.photo.flickrid.should == 'other_guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'other_guesser_person_flickrid'
    guess.guess_text.should == 'other guess text'
    guess.guessed_at.should == Time.utc(2011)
    guess.added_at.should == Time.utc(2012)
  end

  def should_make_labeled_guess(method)
    guess = Guess.send method, 'label'
    guess.photo.flickrid.should == 'label_guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'label_guesser_person_flickrid'
    guess.guess_text.should == 'label_guess text'
  end

end

describe Revelation do
  describe '.make' do
    it "makes one" do
      should_make_default_revelation :make
    end

    it "overrides defaults" do
      should_make_revelation_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_revelation :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database Revelation
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_revelation :make!
    end

    it "overrides defaults" do
      should_make_revelation_with_custom_attributes :make!
    end

    it "labels it" do
      should_make_labeled_revelation :make!
    end

    it "saves it in the database" do
      make_should_save_in_database! Revelation
    end

  end

  def should_make_default_revelation(method)
    revelation = Revelation.send method
    revelation.photo.flickrid.should == 'revelation_photo_flickrid'
    revelation.revelation_text.should == 'revelation text'
    revelation.revealed_at.should_not be_nil
    revelation.added_at.should_not be_nil
  end

  def should_make_revelation_with_custom_attributes(method)
    photo = Photo.send method, 'other_revelation'
    revelation = Revelation.send method,
      :photo => photo,
      :revelation_text => 'other revelation text',
      :revealed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    revelation.photo.flickrid.should == 'other_revelation_photo_flickrid'
    revelation.revelation_text.should == 'other revelation text'
    revelation.revealed_at.should == Time.utc(2011)
    revelation.added_at.should == Time.utc(2012)
  end

  def should_make_labeled_revelation(method)
    revelation = Revelation.send method, 'label'
    revelation.photo.flickrid.should == 'label_revelation_photo_flickrid'
    revelation.revelation_text.should == 'label_revelation text'
  end

end

# Utilities

def make_should_not_save_in_database(model_class)
  model_class.make
  model_class.count.should == 0
end

def make_should_save_in_database!(model_class)
  instance = model_class.make!
  model_class.all.should == [ instance ]
end
