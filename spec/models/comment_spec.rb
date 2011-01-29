require 'spec_helper'
require 'model_factory'

describe Comment do
  it "should belong to a photo" do
    should belong_to :photo
  end

  it "doesn't allow flickrid to be updated" do
    should have_readonly_attribute :flickrid
  end

  it "doesn't allow username to be updated" do
    should have_readonly_attribute :username
  end

  it "doesn't allow comment_text to be updated" do
    should have_readonly_attribute :comment_text
  end

  it "doesn't allow commented_at to be updated" do
    should have_readonly_attribute :commented_at
  end

  describe '.new' do
    VALID_ATTRS = { :flickrid => 'flickrid', :username => 'username',
      :comment_text => 'comment text', :commented_at => Time.now }

    it 'creates a valid object given all required attributes' do
      Comment.new(VALID_ATTRS).should be_valid
    end

    it 'creates an invalid object if flickrid is missing' do
      Comment.new(VALID_ATTRS - :flickrid).should_not be_valid
    end

    it 'creates an invalid object if flickrid is blank' do
      Comment.new(VALID_ATTRS.merge({ :flickrid => '' })).should_not be_valid
    end

    it 'creates an invalid object if username is missing' do
      Comment.new(VALID_ATTRS - :username).should_not be_valid
    end

    it 'creates an invalid object if username is blank' do
      Comment.new(VALID_ATTRS.merge({ :username => '' })).should_not be_valid
    end

    it 'creates an invalid object if comment text is missing' do
      Comment.new(VALID_ATTRS - :comment_text).should_not be_valid
    end

    it 'creates an invalid object if comment_text is blank' do
      Comment.new(VALID_ATTRS.merge({ :comment_text => '' })).should_not be_valid
    end

    it 'creates an invalid object if commented_at is missing' do
      Comment.new(VALID_ATTRS - :commented_at).should_not be_valid
    end

  end

end
