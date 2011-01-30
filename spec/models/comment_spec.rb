require 'spec_helper'
require 'model_factory'

describe Comment do
  describe '#photo' do
    # TODO Dave
    it { should belong_to :photo }
#    it { should validate_presence_of :photo }
#    it { should have_readonly_attribute :photo }
  end

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }
    it { should have_readonly_attribute :username }
  end

  describe '#username' do
    it { should validate_presence_of :comment_text }
    it { should have_readonly_attribute :comment_text }
  end

  describe '#commented_at' do
    it { should validate_presence_of :commented_at }
    it { should have_readonly_attribute :commented_at }
  end

  describe '.new' do
    it 'creates a valid object given all required attributes' do
      Comment.new({ :flickrid => 'flickrid', :username => 'username',
      :comment_text => 'comment text', :commented_at => Time.now }).should be_valid
    end
  end

end
