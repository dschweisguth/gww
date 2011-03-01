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

  describe '#make' do
    before do
      stub(@factory).construction_method { :make }
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

  describe '#make!' do
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
  describe '.make' do
    before do
      set_spec_type FlickrUpdate, false
    end

    it "makes one" do
      should_make_default_flickr_update :make
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make
    end

  end

  describe '.make!' do
    it "makes one" do
      should_make_default_flickr_update :make!
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make!
    end

  end

  def should_make_default_flickr_update(method)
    update = FlickrUpdate.send method
    update.created_at.should_not be_nil
    update.member_count.should == 0
    update.completed_at.should be_nil
  end

  def should_make_flickr_update_with_custom_attributes(method)
    should_make_with_custom_attributes FlickrUpdate, method, {
      :created_at => Time.utc(2011),
      :member_count => 1,
      :completed_at => Time.utc(2011, 2)
    }
  end

end

describe Person do
  describe '.make' do
    before :all do
      stub(Person).construction_method { :make }
    end

    it "makes one" do
      should_make_default_person :make
    end

    it "overrides defaults" do
      should_make_person_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_person :make
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

  end

  def should_make_default_person(method)
    person = Person.send method
    person.flickrid.should == 'person_flickrid'
    person.username.should == 'username'
  end

  def should_make_person_with_custom_attributes(method)
    should_make_with_custom_attributes Person, method, {
      :flickrid => 'other_person_flickrid',
      :username => 'other_username'
    }
  end

  def should_make_labeled_person(method)
    person = Person.send method, 'label'
    person.flickrid.should == 'label_person_flickrid'
    person.username.should == 'label_username'
  end

end

describe Photo do
  describe '.make' do
    before :all do
      stub(Photo).construction_method { :make }
    end

    it "makes one" do
      should_make_default_photo :make
    end

    it "overrides defaults" do
      should_make_photo_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_photo :make
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
    should_make_with_custom_attributes Photo, method, {
      :person => Person.send(method, 'other_poster'),
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

  def should_make_labeled_photo(method)
    photo = Photo.send method, 'label'
    photo.person.flickrid.should == 'label_poster_person_flickrid'
    photo.flickrid.should == 'label_photo_flickrid'
  end

end

describe Comment do
  describe '.make' do
    before :all do
      stub(Comment).construction_method { :make }
    end

    it "makes one" do
      should_make_default_comment :make
    end

    it "overrides defaults" do
      should_make_comment_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_comment :make
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

  end

  def should_make_default_comment(method)
    comment = Comment.send method
    comment.photo.flickrid.should == 'commented_photo_photo_flickrid'
    comment.flickrid.should == 'commenter_flickrid'
    comment.username.should == 'commenter_username'
    comment.comment_text.should == 'comment text'
    comment.commented_at.should_not be_nil
  end

  def should_make_comment_with_custom_attributes(method)
    should_make_with_custom_attributes Comment, method, {
      :photo => Photo.send(method, 'other_commented_photo'),
      :flickrid => 'other_commenter_flickrid',
      :username => 'other_commenter_username',
      :comment_text => 'other comment text',
      :commented_at => Time.utc(2011)
    }
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
    before :all do
      stub(Guess).construction_method { :make }
    end

    it "makes one" do
      should_make_default_guess :make
    end

    it "overrides defaults" do
      should_make_guess_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_guess :make
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
    should_make_with_custom_attributes Guess, method, {
      :photo => Photo.send(method, 'other_guessed_photo'),
      :person => Person.send(method, 'other_guesser'),
      :guess_text => 'other guess text',
      :guessed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    }
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
    before :all do
      stub(Revelation).construction_method { :make }
    end

    it "makes one" do
      should_make_default_revelation :make
    end

    it "overrides defaults" do
      should_make_revelation_with_custom_attributes :make
    end

    it "labels it" do
      should_make_labeled_revelation :make
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

  end

  def should_make_default_revelation(method)
    revelation = Revelation.send method
    revelation.photo.flickrid.should == 'revealed_photo_photo_flickrid'
    revelation.revelation_text.should == 'revelation text'
    revelation.revealed_at.should_not be_nil
    revelation.added_at.should_not be_nil
  end

  def should_make_revelation_with_custom_attributes(method)
    should_make_with_custom_attributes Revelation, method, {
      :photo => Photo.send(method, 'other_revealed_photo'),
      :revelation_text => 'other revelation text',
      :revealed_at => Time.utc(2011),
      :added_at => Time.utc(2012)
    }
  end

  def should_make_labeled_revelation(method)
    revelation = Revelation.send method, 'label'
    revelation.photo.flickrid.should == 'label_revealed_photo_photo_flickrid'
    revelation.revelation_text.should == 'label_revelation text'
  end

end

# Utilities

# Overrides the detected spec type so that we can test both model (in-database)
# and non-model (in-memory) and object creation in this single file
def set_spec_type(model_class, is_model_spec)
  stub(model_class).construction_method { is_model_spec ? :make! : :make }
end

def should_make_with_custom_attributes(model_class, method, attrs_in)
  instance = model_class.send method, attrs_in
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
