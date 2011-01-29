require 'spec_helper'
require 'model_factory'

describe Comment do
  it "should belong to a photo" do
    should belong_to :photo
  end

  it "requires a flickrid" do
    should validate_presence_of :flickrid
  end

  it "doesn't allow flickrid to be updated" do
    should have_readonly_attribute :flickrid
  end

  it "requires a username" do
    should validate_presence_of :username
  end

  it "doesn't allow username to be updated" do
    should have_readonly_attribute :username
  end

  it "requires comment text" do
    should validate_presence_of :comment_text
  end

  it "doesn't allow comment_text to be updated" do
    should have_readonly_attribute :comment_text
  end

  it "requires commented_at" do
    should validate_presence_of :commented_at
  end

  it "doesn't allow commented_at to be updated" do
    should have_readonly_attribute :commented_at
  end

  describe '.new' do
    it 'creates a valid object given all required attributes' do
      Comment.new({ :flickrid => 'flickrid', :username => 'username',
      :comment_text => 'comment text', :commented_at => Time.now }).should be_valid
    end
  end

end
