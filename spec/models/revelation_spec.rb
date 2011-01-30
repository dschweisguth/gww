require 'spec_helper'
require 'support/model_factory'

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

  describe '.longest' do
    it 'lists revelations' do
      revelation = Revelation.create_for_test!
      Revelation.longest.should == [ revelation ]
    end

    it 'sorts revelations by the time from posting to revealing' do
      photo1 = Photo.create_for_test! :label => 1, :dateadded => Time.utc(2000)
      revelation1 = Revelation.create_for_test! :photo => photo1, :revealed_at => Time.utc(2001)
      photo2 = Photo.create_for_test! :label => 2, :dateadded => Time.utc(2002)
      revelation2 = Revelation.create_for_test! :photo => photo2, :revealed_at => Time.utc(2004)
      Revelation.longest.should == [ revelation2, revelation1 ]
    end

  end

end
