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

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      Guess.make! :guess_text => non_ascii_text
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
      guess = Guess.make!
      Guess.destroy_all_by_photo_id guess.photo.id
      Guess.count.should == 0
      Person.exists?(guess.person.id).should == false
    end

    it "ignores other photos' guesses" do
      one_guess = Guess.make! :label => 'one'
      other_guess = Guess.make! :label => 'other'
      Guess.destroy_all_by_photo_id one_guess.photo.id
      Guess.all.should == [ other_guess ]
    end

  end

  describe '.longest' do
    it 'lists guesses sorted by time between post and guess, descending' do
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2000)
      guess1 = Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2002)
      guess2 = Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2004)
      Guess.longest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make! :dateadded => Time.utc(2011)
      Guess.make! :photo => photo, :guessed_at => Time.utc(2010)
      Guess.longest.should == []
    end

  end

  describe '.shortest' do
    it 'lists guesses sorted by time between post and guess, ascending' do
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2000)
      guess1 = Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2002)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2003)
      guess2 = Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2004)
      Guess.shortest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make! :dateadded => Time.utc(2011)
      Guess.make! :photo => photo, :guessed_at => Time.utc(2010)
      Guess.shortest.should == []
    end

  end

  describe '.oldest' do
    it "returns the guesser's guess made the longest after the post" do
      guesser = Person.make!
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2000)
      Guess.make! :label => 1,
        :person => guesser, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2002)
      guess2 = Guess.make! :label => 2,
        :person => guesser, :photo => photo2, :guessed_at => Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess2
      oldest[:place].should == 1
    end

    it "considers other players' guesses when calculating place" do
      guesser = Person.make!
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2000)
      guess1 = Guess.make! :label => 1,
        :person => guesser, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2002)
      Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess1
      oldest[:place].should == 2
    end

    it "ignores a guess that precedes its post" do
      guesser = Person.make!
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2001)
      Guess.make! :label => 1,
        :person => guesser, :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.oldest(guesser).should == nil
    end

  end

  describe '.longest_lasting' do
    it "returns the poster's photo which went unfound the longest" do
      poster = Person.make!
      photo1 = Photo.make! :label => 1, :person => poster, :dateadded => Time.utc(2000)
      Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make! :label => 2, :person => poster, :dateadded => Time.utc(2002)
      guess2 = Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess2
      longest_lasting[:place].should == 1
    end

    it "considers other posters when calculating place" do
      poster = Person.make!
      photo1 = Photo.make! :label => 1, :person => poster, :dateadded => Time.utc(2000)
      guess1 = Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2001)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2002)
      Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess1
      longest_lasting[:place].should == 2
    end

    it 'ignores a guess that precedes its post' do
      poster = Person.make!
      photo1 = Photo.make! :person => poster, :dateadded => Time.utc(2001)
      Guess.make! :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.longest_lasting(poster).should == nil
    end

  end

  describe '.fastest' do
    it "returns the guesser's guess made the fastest after the post" do
      guesser = Person.make!
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2002)
      Guess.make! :label => 1,
        :person => guesser, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2000)
      guess2 = Guess.make! :label => 2,
        :person => guesser, :photo => photo2, :guessed_at => Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess2
      fastest[:place].should == 1
    end

    it "considers other players' guesses when calculating place" do
      guesser = Person.make!
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2002)
      guess1 = Guess.make! :label => 1,
        :person => guesser, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2000)
      Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess1
      fastest[:place].should == 2
    end

    it "ignores a guess that precedes its post" do
      guesser = Person.make!
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2001)
      Guess.make! :label => 1,
        :person => guesser, :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.fastest(guesser).should == nil
    end

  end

  describe '.shortest_lasting' do
    it "returns the guess of the poster's photo which was made the soonest after the post" do
      poster = Person.make!
      photo1 = Photo.make! :label => 1, :person => poster, :dateadded => Time.utc(2002)
      Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make! :label => 2, :person => poster, :dateadded => Time.utc(2000)
      guess2 = Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess2
      shortest_lasting[:place].should == 1
    end

    it "considers other posters when calculating place" do
      poster = Person.make!
      photo1 = Photo.make! :label => 1, :person => poster, :dateadded => Time.utc(2002)
      guess1 = Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2004)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2000)
      Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess1
      shortest_lasting[:place].should == 2
    end

    it 'ignores a guess that precedes its post' do
      poster = Person.make!
      photo1 = Photo.make! :person => poster, :dateadded => Time.utc(2001)
      Guess.make! :photo => photo1, :guessed_at => Time.utc(2000)
      Guess.shortest_lasting(poster).should == nil
    end

  end

  describe '.shortest_in_2010' do
    it 'lists guesses made in 2010 sorted by time between post and guess, ascending' do
      photo1 = Photo.make! :label => 1, :dateadded => Time.utc(2010)
      guess1 = Guess.make! :label => 1, :photo => photo1, :guessed_at => Time.utc(2010, 3)
      photo2 = Photo.make! :label => 2, :dateadded => Time.utc(2010)
      guess2 = Guess.make! :label => 2, :photo => photo2, :guessed_at => Time.utc(2010, 2)
      Guess.shortest_in_2010.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = Photo.make! :dateadded => Time.utc(2010, 2)
      Guess.make! :photo => photo, :guessed_at => Time.utc(2010)
      Guess.shortest_in_2010.should == []
    end

  end

  describe '.all_since' do
    it 'returns all guesses since the most recent Flickr update' do
      guess = Guess.make! :added_at => Time.utc(2011, 1, 2)
      update = FlickrUpdate.make :created_at => Time.utc(2011)
      Guess.all_since(update).should == [ guess ]
    end

    it 'ignores guesses made before the most recent Flickr update' do
      Guess.make! :added_at => Time.utc(2011)
      update = FlickrUpdate.make :created_at => Time.utc(2011, 1, 2)
      Guess.all_since(update).should == []
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
      guess = Guess.make!
      guess.destroy
      Guess.count.should == 0
      Person.exists?(guess.person.id).should == false
    end
  end

end
