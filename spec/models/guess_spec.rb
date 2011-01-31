require 'spec_helper'
require 'support/model_factory'

describe Guess do
  describe '#photo' do
    it { should belong_to :photo }
  end

  describe '#person' do
    it { should belong_to :person }
  end

  describe '#guess_text' do
    it { should validate_presence_of :guess_text }
    it { should have_readonly_attribute :guess_text }
  end

  describe '#guessed_at' do
    it { should validate_presence_of :guessed_at }
    it { should have_readonly_attribute :guessed_at }
  end

  describe '#added_at' do
    it { should validate_presence_of :added_at }
    it { should have_readonly_attribute :added_at }
  end

  describe '.longest' do
    it 'lists the guesses with the longest time between post and guess' do
      photo = Photo.create_for_test! :dateadded => Time.utc(2010)
      guess = Guess.create_for_test! :photo => photo, :guessed_at => Time.utc(2011)
      Guess.longest.should == [ guess ]
    end

    it 'sorts by time between post and guess' do
      photo1 = Photo.create_for_test! :label => 1, :dateadded => Time.utc(2000)
      guess1 = Guess.create_for_test! :label => 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.create_for_test! :label => 2, :dateadded => Time.utc(2002)
      guess2 = Guess.create_for_test! :label => 2, :photo => photo2, :guessed_at => Time.utc(2004)
      Guess.longest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.create_for_test! :dateadded => Time.utc(2011)
      Guess.create_for_test! :photo => photo, :guessed_at => Time.utc(2010)
      Guess.longest.should == []
    end

  end

end
