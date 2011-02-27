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
