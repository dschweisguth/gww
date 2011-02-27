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
      update = FlickrUpdate.make
      update.created_at.should be_nil # Tests always override this
      update.member_count.should == 0
      update.completed_at.should be_nil
    end

    it "doesn't save it in the database" do
      FlickrUpdate.make
      FlickrUpdate.count.should == 0
    end

    it "overrides defaults" do
      created_at = Time.now
      completed_at = Time.now
      update = FlickrUpdate.make \
        :created_at => created_at,
        :member_count => 1,
        :completed_at => completed_at
      update.created_at.should == created_at
      update.member_count.should == 1
      update.completed_at.should == completed_at
    end

  end

  describe 'FlickrUpdate#make!' do
    it "makes a FlickrUpdate" do
      update = FlickrUpdate.make!
      update.created_at.should_not be_nil
      update.member_count.should == 0
      update.completed_at.should be_nil
    end

    it "saves it in the database" do
      update = FlickrUpdate.make!
      FlickrUpdate.all.should == [ update ]
    end

    it "overrides defaults" do
      created_at = Time.utc(2011)
      completed_at = Time.utc(2011, 2)
      update = FlickrUpdate.make! \
        :created_at => created_at,
        :member_count => 1,
        :completed_at => completed_at
      update.created_at.should == created_at
      update.member_count.should == 1
      update.completed_at.should == completed_at
    end

  end

  describe 'Person#make' do
    it 'makes a Person' do
      person = Person.make
      person.flickrid.should == 'person_flickrid'
      person.username.should == 'username'
    end

    it "doesn't save them in the database" do
      Person.make
      Person.count.should == 0
    end

    it 'labels them' do
      person = Person.make 'label'
      person.flickrid.should == 'label_person_flickrid'
      person.username.should == 'label_username'
    end

    it 'overrides_defaults' do
      person = Person.make \
        :flickrid => 'other_person_flickrid',
        :username => 'other_username'
      person.flickrid.should == 'other_person_flickrid'
      person.username.should == 'other_username'
    end

  end

  describe 'Person#make!' do
    it 'makes a Person' do
      person = Person.make!
      person.flickrid.should == 'person_flickrid'
      person.username.should == 'username'
    end

    it 'saves them in the database' do
      person = Person.make!
      Person.all.should == [ person ]
    end

    it 'labels them' do
      person = Person.make! 'label'
      person.flickrid.should == 'label_person_flickrid'
      person.username.should == 'label_username'
    end

    it 'overrides_defaults' do
      person = Person.make! \
        :flickrid => 'other_person_flickrid',
        :username => 'other_username'
      person.flickrid.should == 'other_person_flickrid'
      person.username.should == 'other_username'
    end

  end

end
