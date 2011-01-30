require 'spec_helper'

describe Comment do
  describe '#photo' do
    it { should belong_to :photo }
  end

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }
    it { should have_readonly_attribute :username }
  end

  describe '#comment_text' do
    it { should validate_presence_of :comment_text }
    it { should have_readonly_attribute :comment_text }
  end

  describe '#commented_at' do
    it { should validate_presence_of :commented_at }
    it { should have_readonly_attribute :commented_at }
  end

end
