require 'spec_helper'

describe ModelFactory do
  describe '#make' do
    before do
      @factory = Object.new
      #noinspection RubyResolve
      @factory.extend ModelFactory

      @model_object = Object.new
      class << @model_object
        attr_accessor :id
      end

    end

    it "handles no args" do
      mock(@factory).options(:make, '', {}) { {} }
      mock(@factory).send(:new, {}) { @model_object }
      @factory.make
    end

    it "handles options" do
      mock(@factory).options(:make, '', { :other_option => 'other_option' }) { {} }
      mock(@factory).send(:new, { :other_option => 'other_option' }) { @model_object }
      @factory.make :other_option => 'other_option'
    end

    it "handles a label passed in as a string" do
      mock(@factory).options(:make, 'xxx_', {}) { {} }
      mock(@factory).send(:new, {}) { @model_object }
      @factory.make 'xxx'
    end

    it "handles a label passed in as a string plus options" do
      mock(@factory).options(:make, 'xxx_', { :other_option => 'other_option' }) { {} }
      mock(@factory).send(:new, { :other_option => 'other_option' }) { @model_object }
      @factory.make 'xxx', :other_option => 'other_option'
    end

    it "creates, too" do
      mock(@factory).options(:make!, '', {}) { {} }
      mock(@factory).send :create!, {}
      @factory.make!
    end

    it "allows you to specify id" do
      mock(@factory).options(:make, '', {}) { {} }
      mock(@factory).send(:new, {}) { @model_object }
      model_object_out = @factory.make :id => 666
      model_object_out.id.should == 666
    end

    it "blows up if you try to specify id for an object that will be saved in the database" do
      lambda { @factory.make! :id => 1 }.should raise_error ArgumentError
    end

  end
end

describe FlickrUpdate do
  describe '.make' do
    it "makes one" do
      should_make_default_flickr_update :make
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make, :id => 1
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
      should_make_flickr_update_with_custom_attributes :make!, {}
    end

    it "saves it in the database" do
      make_should_save_in_database! FlickrUpdate
    end

  end

  def should_make_default_flickr_update(method)
    update = FlickrUpdate.send method
    id_should_have_default_value method, update
    update.created_at.should_not be_nil
    update.member_count.should == 0
    update.completed_at.should be_nil
  end

  def should_make_flickr_update_with_custom_attributes(method, extra_attrs)
    attrs = {
      :created_at => Time.utc(2011),
      :member_count => 1,
      :completed_at => Time.utc(2011, 2)
    }
    should_make_with_custom_attributes method, FlickrUpdate, attrs, extra_attrs
  end

end

describe Person do
  describe '.make' do
    it "makes one" do
      should_make_default_person :make
    end

    it "overrides defaults" do
      should_make_person_with_custom_attributes :make, :id => 1
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
      should_make_person_with_custom_attributes :make!, {}
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
    id_should_have_default_value method, person
    person.flickrid.should == 'person_flickrid'
    person.username.should == 'username'
  end

  def should_make_person_with_custom_attributes(method, extra_attrs)
    attrs = {
      :flickrid => 'other_person_flickrid',
      :username => 'other_username'
    }
    should_make_with_custom_attributes method, Person, attrs, extra_attrs
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
      should_make_photo_with_custom_attributes :make, :id => 1
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
      should_make_photo_with_custom_attributes :make!, {}
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
    id_should_have_default_value method, photo
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

  def should_make_photo_with_custom_attributes(method, extra_attrs)
    person = Person.send method, 'other_poster'
    attrs = {
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
    }
    photo = should_make_with_custom_attributes method, Photo, attrs, extra_attrs
    photo.person.flickrid.should == 'other_poster_person_flickrid'
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
      should_make_comment_with_custom_attributes :make, :id => 1
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
      should_make_comment_with_custom_attributes :make!, {}
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
    id_should_have_default_value method, comment
    comment.photo.flickrid.should == 'commented_photo_photo_flickrid'
    comment.flickrid.should == 'commenter_flickrid'
    comment.username.should == 'commenter_username'
    comment.comment_text.should == 'comment text'
    comment.commented_at.should_not be_nil
  end

  def should_make_comment_with_custom_attributes(method, extra_attrs)
    photo = Photo.send method, 'other_commented_photo'
    attrs = {
      :photo => photo,
      :flickrid => 'other_commenter_flickrid',
      :username => 'other_commenter_username',
      :comment_text => 'other comment text',
      :commented_at => Time.utc(2011)
    }
    comment = should_make_with_custom_attributes method, Comment, attrs, extra_attrs
    comment.photo.flickrid.should == 'other_commented_photo_photo_flickrid'
  end

  def should_make_labeled_comment(method)
    comment = Comment.send method, 'label'
    comment.photo.flickrid.should == 'label_commented_photo_photo_flickrid'
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
      should_make_guess_with_custom_attributes :make, :id => 1
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
      should_make_guess_with_custom_attributes :make!, {}
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
    id_should_have_default_value method, guess
    guess.photo.flickrid.should == 'guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'guesser_person_flickrid'
    guess.guess_text.should == 'guess text'
    guess.guessed_at.should_not be_nil
    guess.added_at.should_not be_nil
  end

  def should_make_guess_with_custom_attributes(method, extra_attrs)
    photo = Photo.send method, 'other_guessed_photo'
    guesser = Person.send method, 'other_guesser'
    attrs = {
      :photo => photo,
      :person => guesser,
      :guess_text => 'other guess text',
      :guessed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    }
    guess = should_make_with_custom_attributes method, Guess, attrs, extra_attrs
    guess.photo.flickrid.should == 'other_guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'other_guesser_person_flickrid'
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
      should_make_revelation_with_custom_attributes :make, :id => 1
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
      should_make_revelation_with_custom_attributes :make!, {}
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
    id_should_have_default_value method, revelation
    revelation.photo.flickrid.should == 'revealed_photo_photo_flickrid'
    revelation.revelation_text.should == 'revelation text'
    revelation.revealed_at.should_not be_nil
    revelation.added_at.should_not be_nil
  end

  def should_make_revelation_with_custom_attributes(method, extra_attrs)
    photo = Photo.send method, 'other_revealed_photo'
    attrs = {
      :photo => photo,
      :revelation_text => 'other revelation text',
      :revealed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    }
    revelation = should_make_with_custom_attributes method, Revelation, attrs, extra_attrs
    revelation.photo.flickrid.should == 'other_revealed_photo_photo_flickrid'
  end

  def should_make_labeled_revelation(method)
    revelation = Revelation.send method, 'label'
    revelation.photo.flickrid.should == 'label_revealed_photo_photo_flickrid'
    revelation.revelation_text.should == 'label_revelation text'
  end

end

# Utilities

def id_should_have_default_value(method, object)
  if method == :make
    object.id.should == 0
  else
    object.id.should_not be_nil
  end
end

def should_make_with_custom_attributes(method, model_class, attrs, extra_attrs)
  object = model_class.send method, attrs.merge(extra_attrs)
  if method == :make
    object.id.should == extra_attrs[:id]
  else
    object.id.should_not be_nil
  end
  should_have_attrs object, attrs
  object
end

def should_have_attrs(object, expected_attrs)
  munged_actual_attrs = {}
  actual_attrs = object.attributes
  actual_attrs.each_pair do |key, val|
    if key =~ /^(.*)_id$/ && val.nil?
      val = object.send($1).id
    end
    munged_actual_attrs[key] = val
  end

  munged_expected_attrs = {}
  expected_attrs.each_pair do |key, val|
    key = key.to_s
    if val.is_a? ActiveRecord::Base
      key += "_id"
      val = val.id
    end
    munged_expected_attrs[key] = val
  end

  munged_actual_attrs.except('id').should == munged_expected_attrs
end

def make_should_not_save_in_database(model_class)
  model_class.make
  model_class.count.should == 0
end

def make_should_save_in_database!(model_class)
  instance = model_class.make!
  model_class.all.should == [ instance ]
end
