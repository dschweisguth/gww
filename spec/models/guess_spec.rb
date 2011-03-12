require 'spec_helper'

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

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      Guess.make :guess_text => non_ascii_text
      Guess.all[0].guess_text.should == non_ascii_text
    end

  end

  describe '#guessed_at' do
    it { should validate_presence_of :guessed_at }
    it { should have_readonly_attribute :guessed_at }
  end

  describe '#added_at' do
    it { should validate_presence_of :added_at }
    it { should have_readonly_attribute :added_at }
  end

  describe '.destroy_all_by_photo_id' do
    it 'destroys all guesses of the photo with the given id' do
      guess = Guess.make
      Guess.destroy_all_by_photo_id guess.photo.id
      Guess.count.should == 0
      owner_doesnt_exist guess
    end

    it "ignores other photos' guesses" do
      one_guess = Guess.make 'one'
      other_guess = Guess.make 'other'
      Guess.destroy_all_by_photo_id one_guess.photo.id
      Guess.all.should == [ other_guess ]
    end

  end

  describe '.longest' do
    it 'lists guesses sorted by time between post and guess, descending' do
      photo1 = Photo.make 1, :dateadded => Time.utc(2000)
      guess1 = Guess.make 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make 2, :dateadded => Time.utc(2002)
      guess2 = Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2004)
      Guess.longest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make :dateadded => Time.utc(2011)
      Guess.make :photo => photo, :guessed_at => Time.utc(2010)
      Guess.longest.should == []
    end

  end

  describe '.shortest' do
    it 'lists guesses sorted by time between post and guess, ascending' do
      photo1 = Photo.make 1, :dateadded => Time.utc(2000)
      guess1 = Guess.make 1, :photo => photo1, :guessed_at => Time.utc(2002)
      photo2 = Photo.make 2, :dateadded => Time.utc(2003)
      guess2 = Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2004)
      Guess.shortest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make :dateadded => Time.utc(2011)
      Guess.make :photo => photo, :guessed_at => Time.utc(2010)
      Guess.shortest.should == []
    end

  end

  describe '.first_by' do
    it "returns the guesser's first guess" do
      guesser = Person.make
      Guess.make 'second', :person => guesser, :guessed_at => Time.utc(2001)
      first = Guess.make 'first', :person => guesser, :guessed_at => Time.utc(2000)
      Guess.first_by(guesser).should == first
    end

    it "ignores other players' guesses" do
      Guess.make
      Guess.first_by(Person.make).should be_nil
    end

  end

  describe '.most_recent_by' do
    it "returns the guesser's most recent guess" do
      guesser = Person.make
      Guess.make 'penultimate', :person => guesser, :guessed_at => Time.utc(2000)
      most_recent = Guess.make 'most_recent', :person => guesser, :guessed_at => Time.utc(2001)
      Guess.most_recent_by(guesser).should == most_recent
    end

    it "ignores other players' guesses" do
      Guess.make
      Guess.most_recent_by(Person.make).should be_nil
    end

  end

  describe '.oldest' do
    it "returns the guesser's guess made the longest after the post" do
      guesser = Person.make
      photo1 = Photo.make 1, :dateadded => Time.utc(2000)
      Guess.make 1, :person => guesser, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make 2, :dateadded => Time.utc(2002)
      guess2 = Guess.make 2,
        :person => guesser, :photo => photo2, :guessed_at => Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess2
      oldest[:place].should == 1
    end

    it "ignores other players' guesses" do
      Guess.make
      Guess.oldest(Person.make).should be_nil
    end

    it "considers other players' guesses when calculating place" do
      guesser = Person.make
      photo1 = Photo.make 1, :dateadded => Time.utc(2000)
      guess1 = Guess.make 1, :person => guesser, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make 2, :dateadded => Time.utc(2002)
      Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess1
      oldest[:place].should == 2
    end

    it "ignores a guess that precedes its post" do
      guesser = Person.make
      photo1 = Photo.make 1, :dateadded => Time.utc(2001)
      Guess.make 1, :person => guesser, :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.oldest(guesser).should == nil
    end

  end

  describe '.longest_lasting' do
    it "returns the poster's photo which went unfound the longest" do
      poster = Person.make
      photo1 = Photo.make 1, :person => poster, :dateadded => Time.utc(2000)
      Guess.make 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make 2, :person => poster, :dateadded => Time.utc(2002)
      guess2 = Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess2
      longest_lasting[:place].should == 1
    end

    it "ignores guesses of other players' posts" do
      Guess.make 2
      Guess.longest_lasting(Photo.make(1).person).should be_nil
    end

    it "considers other posters when calculating place" do
      poster = Person.make
      photo1 = Photo.make 1, :person => poster, :dateadded => Time.utc(2000)
      guess1 = Guess.make 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make 2, :dateadded => Time.utc(2002)
      Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess1
      longest_lasting[:place].should == 2
    end

    it 'ignores a guess that precedes its post' do
      poster = Person.make
      photo1 = Photo.make :person => poster, :dateadded => Time.utc(2001)
      Guess.make :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.longest_lasting(poster).should == nil
    end

  end

  describe '.fastest' do
    it "returns the guesser's guess made the fastest after the post" do
      guesser = Person.make
      photo1 = Photo.make 1, :dateadded => Time.utc(2002)
      Guess.make 1, :person => guesser, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make 2, :dateadded => Time.utc(2000)
      guess2 = Guess.make 2, :person => guesser, :photo => photo2, :guessed_at => Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess2
      fastest[:place].should == 1
    end

    it "ignores other players' guesses" do
      Guess.make
      Guess.fastest(Person.make).should be_nil
    end

    it "considers other players' guesses when calculating place" do
      guesser = Person.make
      photo1 = Photo.make 1, :dateadded => Time.utc(2002)
      guess1 = Guess.make 1, :person => guesser, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make 2, :dateadded => Time.utc(2000)
      Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess1
      fastest[:place].should == 2
    end

    it "ignores a guess that precedes its post" do
      guesser = Person.make
      photo1 = Photo.make 1, :dateadded => Time.utc(2001)
      Guess.make 1, :person => guesser, :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.fastest(guesser).should == nil
    end

  end

  describe '.shortest_lasting' do
    it "returns the guess of the poster's photo which was made the soonest after the post" do
      poster = Person.make
      photo1 = Photo.make 1, :person => poster, :dateadded => Time.utc(2002)
      Guess.make 1, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make 2, :person => poster, :dateadded => Time.utc(2000)
      guess2 = Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess2
      shortest_lasting[:place].should == 1
    end

    it "ignores guesses of other players' posts" do
      Guess.make 2
      Guess.shortest_lasting(Photo.make(1).person).should be_nil
    end

    it "considers other posters when calculating place" do
      poster = Person.make
      photo1 = Photo.make 1, :person => poster, :dateadded => Time.utc(2002)
      guess1 = Guess.make 1, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make 2, :dateadded => Time.utc(2000)
      Guess.make 2, :photo => photo2, :guessed_at => Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess1
      shortest_lasting[:place].should == 2
    end

    it 'ignores a guess that precedes its post' do
      poster = Person.make
      photo1 = Photo.make :person => poster, :dateadded => Time.utc(2001)
      Guess.make :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.shortest_lasting(poster).should == nil
    end

  end

  describe '.longest_in' do
    it 'lists guesses made in the given year sorted by time between post and guess, descending' do
      photo1 = Photo.make 1, :dateadded => Time.local(2010).getutc
      guess1 = Guess.make 1, :photo => photo1, :guessed_at => Time.local(2010, 2).getutc
      photo2 = Photo.make 2, :dateadded => Time.local(2010).getutc
      guess2 = Guess.make 2, :photo => photo2, :guessed_at => Time.local(2010, 3).getutc
      Guess.longest_in(2010).should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make :dateadded => Time.local(2010, 2).getutc
      Guess.make :photo => photo, :guessed_at => Time.local(2010).getutc
      Guess.longest_in(2010).should == []
    end

  end

  describe '.shortest_in' do
    it 'lists guesses made in the given year sorted by time between post and guess, ascending' do
      photo1 = Photo.make 1, :dateadded => Time.local(2010).getutc
      guess1 = Guess.make 1, :photo => photo1, :guessed_at => Time.local(2010, 3).getutc
      photo2 = Photo.make 2, :dateadded => Time.local(2010).getutc
      guess2 = Guess.make 2, :photo => photo2, :guessed_at => Time.local(2010, 2).getutc
      Guess.shortest_in(2010).should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make :dateadded => Time.local(2010, 2).getutc
      Guess.make :photo => photo, :guessed_at => Time.local(2010).getutc
      Guess.shortest_in(2010).should == []
    end

  end

  describe '.all_between' do
    it 'returns all guesses between the given dates' do
      guess = Guess.make :added_at => Time.utc(2011, 1, 1, 0, 0, 1)
      Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == [ guess ]
    end

    it 'ignores guesses made on or before the from date' do
      Guess.make :added_at => Time.utc(2011)
      Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == []
    end

    it 'ignores guesses made after the to date' do
      Guess.make :added_at => Time.utc(2011, 1, 1, 0, 0, 2)
      Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == []
    end

  end

  describe '#years_old' do
    it 'returns the number of full years from post to guess (ignoring leap years)' do
      photo = Photo.new :dateadded => Time.utc(2010)
      guess = Guess.new :photo => photo, :guessed_at => Time.utc(2011)
      guess.years_old.should == 1
    end
  end

  describe '#seconds_old' do
    it 'returns the number of full seconds from post to guess' do
      photo = Photo.new :dateadded => Time.utc(2010)
      guess = Guess.new :photo => photo, :guessed_at => Time.utc(2010, 1, 1, 0, 0, 1)
      guess.seconds_old.should == 1
    end
  end

  describe '#time_elapsed' do
    it 'returns the duration in seconds from post to guess in English' do
      photo = Photo.new :dateadded => Time.utc(2000)
      guess = Guess.new :photo => photo, :guessed_at => Time.utc(2001, 2, 2, 1, 1, 1)
      guess.time_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second';
    end
  end

  describe '#ymd_elapsed' do
    it 'returns the duration in days from post to guess in English' do
      photo = Photo.new :dateadded => Time.utc(2000)
      guess = Guess.new :photo => photo, :guessed_at => Time.utc(2001, 2, 2, 1, 1, 1)
      guess.ymd_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day';
    end
  end

  describe '#star_for_age' do
    expected = { 2000 => nil, 2001 => :bronze, 2002 => :silver, 2003 => :gold }
    expected.keys.sort.each do |year_guessed|
      it "returns a #{expected[year_guessed]} star for a #{year_guessed - 2000}-year-old guess" do
        photo = Photo.new :dateadded => Time.utc(2000)
        guess = Guess.new :photo => photo, :guessed_at => Time.utc(year_guessed)
        guess.star_for_age.should == expected[year_guessed]
      end
    end
  end

  describe '#star_for_speed' do
    expected = { 10 => :gold, 11 => :silver, 60 => :silver, 61 => nil }
    expected.keys.sort.each do |seconds_guessed|
      it "returns a #{expected[seconds_guessed]} star for a #{seconds_guessed}-second-old guess" do
        photo = Photo.new :dateadded => Time.utc(2000)
        guess = Guess.new :photo => photo, :guessed_at => Time.utc(2000) + seconds_guessed
        guess.star_for_speed.should == expected[seconds_guessed]
      end
    end
  end

  describe '#destroy' do
    it 'destroys the guess and its person' do
      guess = Guess.make
      guess.destroy
      Guess.count.should == 0
      owner_doesnt_exist guess
    end
  end

  # Used by specs which delete a guess to assert that the owner had no
  # other photos or other guesses, so they should have been deleted too.
  # It would be nice to mock the method that deletes the owner, which handles
  # cases where the owner has a photo or other guess and shouldn't be deleted,
  # but doing so would be ugly.
  def owner_doesnt_exist(guess)
    Person.exists?(guess.person.id).should == false
  end

end
