require 'spec_helper'

describe ModelFactory do
  before do
    @factory = Object.new
    #noinspection RubyResolve
    @factory.extend ModelFactory

    @model_object = Object.new
    class << @model_object
      attr_accessor :id
    end

  end

  describe 'when using .new' do
    before do
      set_spec_type_to_non_model @factory
    end

    it "handles no args" do
      mock(@factory).options(:make, '', {}) { {} }
      mock(@factory).send(:new, {}) { @model_object }
      instance = @factory.make
      instance.id.should == 0 # i.e. it sets a default ID
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

    it "allows you to override the default id" do
      mock(@factory).options(:make, '', {}) { {} }
      mock(@factory).send(:new, {}) { @model_object }
      model_object_out = @factory.make :id => 666
      model_object_out.id.should == 666
    end

  end

  describe 'when using .create!' do
    it "creates, too" do
      mock(@factory).options(:make!, '', {}) { {} }
      @model_object.id = 666
      mock(@factory).send(:create!, {}) { @model_object }
      instance = @factory.make
      instance.id.should == 666 # i.e. it leaves the ActiveRecord ID alone
    end

    it "blows up if you try to override the default id for an instance that will be saved in the database" do
      lambda { @factory.make :id => 1 }.should raise_error ArgumentError
    end
    
  end

end

describe FlickrUpdate do
  describe 'when using .new' do
    before do
      set_spec_type_to_non_model
    end

    it "makes one" do
      should_make_default_flickr_update
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes
    end

  end

  describe 'when using .create!' do
    it "makes one" do
      should_make_default_flickr_update
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes
    end

  end

  def should_make_default_flickr_update
    update = FlickrUpdate.make
    update.created_at.should_not be_nil
    update.member_count.should == 0
    update.completed_at.should be_nil
  end

  def should_make_flickr_update_with_custom_attributes
    should_make_with_custom_attributes FlickrUpdate, {
      :created_at => Time.utc(2011),
      :member_count => 1,
      :completed_at => Time.utc(2011, 2)
    }
  end

end

describe Person do
  describe 'when using .new' do
    before do
      set_spec_type_to_non_model
    end

    it "makes one" do
      should_make_default_person
    end

    it "overrides defaults" do
      should_make_person_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_person
    end

  end

  describe 'when using .create!' do
    it "makes one" do
      should_make_default_person
    end

    it "overrides_defaults" do
      should_make_person_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_person
    end

  end

  def should_make_default_person
    person = Person.make
    person.flickrid.should == 'person_flickrid'
    person.username.should == 'username'
  end

  def should_make_person_with_custom_attributes
    should_make_with_custom_attributes Person, {
      :flickrid => 'other_person_flickrid',
      :username => 'other_username'
    }
  end

  def should_make_labeled_person
    person = Person.make 'label'
    person.flickrid.should == 'label_person_flickrid'
    person.username.should == 'label_username'
  end

end

describe Photo do
  describe 'when using .new' do
    before do
      set_spec_type_to_non_model
    end

    it "makes one" do
      should_make_default_photo
    end

    it "overrides defaults" do
      should_make_photo_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_photo
    end

  end

  describe 'when using .create!' do
    it "makes one" do
      should_make_default_photo
    end

    it "overrides defaults" do
      should_make_photo_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_photo
    end

  end

  def should_make_default_photo
    photo = Photo.make
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

  def should_make_photo_with_custom_attributes
    should_make_with_custom_attributes Photo, {
      :person => Person.make('other_poster'),
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
  end

  def should_make_labeled_photo
    photo = Photo.make 'label'
    photo.person.flickrid.should == 'label_poster_person_flickrid'
    photo.flickrid.should == 'label_photo_flickrid'
  end

end

describe Comment do
  describe 'when using .new' do
    before do
      set_spec_type_to_non_model
    end

    it "makes one" do
      should_make_default_comment
    end

    it "overrides defaults" do
      should_make_comment_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_comment
    end

  end

  describe 'when using .create!' do
    it "makes one" do
      should_make_default_comment
    end

    it "overrides defaults" do
      should_make_comment_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_comment
    end

  end

  def should_make_default_comment
    comment = Comment.make
    comment.photo.flickrid.should == 'commented_photo_photo_flickrid'
    comment.flickrid.should == 'commenter_flickrid'
    comment.username.should == 'commenter_username'
    comment.comment_text.should == 'comment text'
    comment.commented_at.should_not be_nil
  end

  def should_make_comment_with_custom_attributes
    should_make_with_custom_attributes Comment, {
      :photo => Photo.make('other_commented_photo'),
      :flickrid => 'other_commenter_flickrid',
      :username => 'other_commenter_username',
      :comment_text => 'other comment text',
      :commented_at => Time.utc(2011)
    }
  end

  def should_make_labeled_comment
    comment = Comment.make 'label'
    comment.photo.flickrid.should == 'label_commented_photo_photo_flickrid'
    comment.flickrid.should == 'label_commenter_flickrid'
    comment.username.should == 'label_commenter_username'
    comment.comment_text.should == 'label_comment text'
  end

end

describe Guess do
  describe 'when using .new' do
    before do
      set_spec_type_to_non_model
    end

    it "makes one" do
      should_make_default_guess
    end

    it "overrides defaults" do
      should_make_guess_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_guess
    end

  end

  describe 'when using .create!' do
    it "makes one" do
      should_make_default_guess
    end

    it "overrides defaults" do
      should_make_guess_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_guess
    end

  end

  def should_make_default_guess
    guess = Guess.make
    guess.photo.flickrid.should == 'guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'guesser_person_flickrid'
    guess.guess_text.should == 'guess text'
    guess.guessed_at.should_not be_nil
    guess.added_at.should_not be_nil
  end

  def should_make_guess_with_custom_attributes
    should_make_with_custom_attributes Guess, {
      :photo => Photo.make('other_guessed_photo'),
      :person => Person.make('other_guesser'),
      :guess_text => 'other guess text',
      :guessed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    }
  end

  def should_make_labeled_guess
    guess = Guess.make 'label'
    guess.photo.flickrid.should == 'label_guessed_photo_photo_flickrid'
    guess.person.flickrid.should == 'label_guesser_person_flickrid'
    guess.guess_text.should == 'label_guess text'
  end

end

describe Revelation do
  describe 'when using .new' do
    before do
      set_spec_type_to_non_model
    end

    it "makes one" do
      should_make_default_revelation
    end

    it "overrides defaults" do
      should_make_revelation_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_revelation
    end

  end

  describe 'when using .create!' do
    it "makes one" do
      should_make_default_revelation
    end

    it "overrides defaults" do
      should_make_revelation_with_custom_attributes
    end

    it "labels it" do
      should_make_labeled_revelation
    end

  end

  def should_make_default_revelation
    revelation = Revelation.make
    revelation.photo.flickrid.should == 'revealed_photo_photo_flickrid'
    revelation.revelation_text.should == 'revelation text'
    revelation.revealed_at.should_not be_nil
    revelation.added_at.should_not be_nil
  end

  def should_make_revelation_with_custom_attributes
    should_make_with_custom_attributes Revelation, {
      :photo => Photo.make('other_revealed_photo'),
      :revelation_text => 'other revelation text',
      :revealed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    }
  end

  def should_make_labeled_revelation
    revelation = Revelation.make 'label'
    revelation.photo.flickrid.should == 'label_revealed_photo_photo_flickrid'
    revelation.revelation_text.should == 'label_revelation text'
  end

end

# Utilities

# Overrides the detected spec type so that we can test both model (in-database)
# and non-model (in-memory) and object creation in this single file
def set_spec_type_to_non_model(*model_classes)
  if model_classes.empty?
    model_classes = [ FlickrUpdate, Person, Photo, Comment, Guess, Revelation ]
  end
  model_classes.each { |model_class| stub(model_class).construction_method { :make } }
end

def should_make_with_custom_attributes(model_class, attrs_in)
  instance = model_class.make attrs_in
  actual_attrs = update_nil_id_attributes instance
  expected_attrs = replace_object_attributes_with_id_attributes stringify_keys attrs_in
  actual_attrs.except('id').should == expected_attrs.except('id')
end

# A nil ID attr means that this object hasn't been saved, so the ID of the
# object attr corresponding to the ID hasn't been copied to the ID attr.
# This method does that.
def update_nil_id_attributes object
  updated_attrs = {}
  object.attributes.each_pair do |key, val|
    if key =~ /^(.*)_id$/ && val.nil?
      val = object.send($1).id
    end
    updated_attrs[key] = val
  end
  updated_attrs
end

def replace_object_attributes_with_id_attributes attrs
  updated_attrs = {}
  attrs.each_pair do |key, val|
    if val.is_a? ActiveRecord::Base
      key += "_id"
      val = val.id
    end
    updated_attrs[key] = val
  end
  updated_attrs
end

def stringify_keys attrs
  Hash[attrs.to_a.map { |pair| [ pair[0].to_s, pair[1] ] }]
end
