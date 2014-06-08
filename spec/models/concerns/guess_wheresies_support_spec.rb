require 'spec_helper'

describe GuessWheresiesSupport do
  describe '.longest_in' do
    it 'lists guesses made in the given year sorted by time between post and guess, descending' do
      photo1 = create :photo, dateadded: Time.local(2010).getutc
      guess1 = create :guess, photo: photo1, commented_at: Time.local(2010, 2).getutc
      photo2 = create :photo, dateadded: Time.local(2010).getutc
      guess2 = create :guess, photo: photo2, commented_at: Time.local(2010, 3).getutc
      Guess.longest_in(2010).should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = create :photo, dateadded: Time.local(2010, 2).getutc
      create :guess, photo: photo, commented_at: Time.local(2010).getutc
      Guess.longest_in(2010).should == []
    end

  end

  describe '.shortest_in' do
    it 'lists guesses made in the given year sorted by time between post and guess, ascending' do
      photo1 = create :photo, dateadded: Time.local(2010).getutc
      guess1 = create :guess, photo: photo1, commented_at: Time.local(2010, 3).getutc
      photo2 = create :photo, dateadded: Time.local(2010).getutc
      guess2 = create :guess, photo: photo2, commented_at: Time.local(2010, 2).getutc
      Guess.shortest_in(2010).should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = create :photo, dateadded: Time.local(2010, 2).getutc
      create :guess, photo: photo, commented_at: Time.local(2010).getutc
      Guess.shortest_in(2010).should == []
    end

  end

end
