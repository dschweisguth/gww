require 'spec_helper'

describe Revelation do

  describe '#photo' do
    it { should belong_to :photo }
  end

  describe '#revelation_text' do
    it { should validate_presence_of :revelation_text }
    it { should have_readonly_attribute :revelation_text }
  end

  describe '#revealed_at' do
    it { should validate_presence_of :revealed_at }
    it { should have_readonly_attribute :revealed_at }
  end

  describe '#added_at' do
    it { should validate_presence_of :added_at }
    it { should have_readonly_attribute :added_at }
  end

end
