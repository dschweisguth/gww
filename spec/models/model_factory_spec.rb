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

  describe 'FlickrUpdate#make' do
    it "makes a FlickrUpdate" do
      should_make_default_flickr_update :make, true
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make
    end

    it "doesn't save it in the database" do
      make_should_not_save_in_database FlickrUpdate
    end

  end

  describe 'FlickrUpdate#make!' do
    it "makes a FlickrUpdate" do
      should_make_default_flickr_update :make!, false
    end

    it "overrides defaults" do
      should_make_flickr_update_with_custom_attributes :make!
    end

    it "saves it in the database" do
      make_bang_should_save_in_database FlickrUpdate
    end

  end

  def should_make_default_flickr_update(method, created_at_should_be_nil)
    update = FlickrUpdate.send method
    update.created_at.nil?.should == created_at_should_be_nil
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

  describe 'Person#make' do
    it "makes a Person" do
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

  describe 'Person#make!' do
    it "makes a Person" do
      should_make_default_person :make!
    end

    it "overrides_defaults" do
      should_make_person_with_custom_attributes :make!
    end

    it "labels it" do
      should_make_labeled_person :make!
    end

    it "saves it in the database" do
      make_bang_should_save_in_database Person
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

  describe 'Photo.make' do
    it "makes a Photo" do
      photo = Photo.make
      photo.person.flickrid.should == 'poster_person_flickrid'
      photo.person.username.should == 'poster_username'
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

    it "doesn't save it in the database" do
      Photo.make
      Photo.count.should == 0
    end

    it "labels it" do
      photo = Photo.make 'label'
      photo.person.flickrid.should == 'label_poster_person_flickrid'
      photo.person.username.should == 'label_poster_username'
    end

    it "overrides defaults" do
      person = Person.make \
        :flickrid => 'other_person_flickrid',
        :username => 'other_username'
      photo = Photo.make \
        :person => person,
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
      photo.person.flickrid.should == 'other_person_flickrid'
      photo.person.username.should == 'other_username'
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

  end

  describe 'Photo.make!' do
    it "makes a Photo" do
      photo = Photo.make!
      photo.person.flickrid.should == 'poster_person_flickrid'
      photo.person.username.should == 'poster_username'
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

    it "saves it in the database" do
      photo = Photo.make!
      Photo.all.should == [ photo ]
    end

    it "labels it" do
      photo = Photo.make! 'label'
      photo.person.flickrid.should == 'label_poster_person_flickrid'
      photo.person.username.should == 'label_poster_username'
    end

    it "overrides defaults" do
      person = Person.make! \
        :flickrid => 'other_person_flickrid',
        :username => 'other_username'
      photo = Photo.make! \
        :person => person,
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
      photo.person.flickrid.should == 'other_person_flickrid'
      photo.person.username.should == 'other_username'
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

  end

  # Utilities

  def make_should_not_save_in_database(model_class)
    model_class.make
    model_class.count.should == 0
  end

  def make_bang_should_save_in_database(model_class)
    instance = model_class.make!
    model_class.all.should == [ instance ]
  end

end
