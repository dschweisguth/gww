require 'spec_helper'

describe Guess do
  describe '#person_id' do
    it "is unique for a given photo and comment text" do
      existing = create :guess
      build(:guess, photo: existing.photo, person: existing.person, comment_text: existing.comment_text).should_not be_valid
    end

    it "need not be unique if the photo is different" do
      existing = create :guess
      build(:guess, person: existing.person, comment_text: existing.comment_text).should be_valid
    end

    it "need not be unique if the comment_text is different" do
      existing = create :guess
      build(:guess, photo: existing.photo, person: existing.person).should be_valid
    end

  end

  describe '#comment_text' do
    it { should validate_presence_of :comment_text }

    it 'should handle non-ASCII characters' do
      non_ascii_text = 'π is rad'
      create :guess, comment_text: non_ascii_text
      Guess.all[0].comment_text.should == non_ascii_text
    end

  end

  describe '#commented_at' do
    it { should validate_presence_of :commented_at }
  end

  describe '#added_at' do
    it { should validate_presence_of :added_at }
  end

  describe '#destroy' do
    let(:guess) { create :guess }
    let(:person) { guess.person }

    it "destroys the guess and its person" do
      guess.destroy
      Guess.any?.should be_false
      Person.exists?(person.id).should be_false
      Photo.exists?(guess.photo.id).should be_true
    end

    it "leaves the person alone if they have another guess" do
      create :guess, person: person
      guess.destroy
      Guess.exists?(guess.id).should be_false
      Person.exists?(person.id).should be_true
      Photo.exists?(guess.photo.id).should be_true
    end

    it "leaves the person alone if they have a photo" do
      create :photo, person: person
      guess.destroy
      Guess.any?.should be_false
      Person.exists?(person.id).should be_true
      Photo.exists?(guess.photo.id).should be_true
    end

  end

  describe '.destroy_all_by_photo_id' do
    let(:guess) { create :guess }

    it 'destroys all guesses of the photo with the given id' do
      Guess.destroy_all_by_photo_id guess.photo.id
      Guess.any?.should be_false
    end

    it "ignores other photos' guesses" do
      other_guess = create :guess
      Guess.destroy_all_by_photo_id guess.photo.id
      Guess.all.should == [ other_guess ]
    end

  end

  describe '.longest' do
    it 'lists guesses sorted by time between post and guess, descending' do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      Guess.longest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, commented_at: Time.utc(2010)
      Guess.longest.should == []
    end

  end

  describe '.shortest' do
    it 'lists guesses sorted by time between post and guess, ascending' do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2002)
      photo2 = create :photo, dateadded: Time.utc(2003)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      Guess.shortest.should == [ guess2, guess1 ]
    end

    it 'ignores a guess made before it was posted' do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, commented_at: Time.utc(2010)
      Guess.shortest.should == []
    end

  end

  describe '.first_by' do
    let(:guesser) { create :person }

    it "returns the guesser's first guess" do
      create :guess, person: guesser, commented_at: Time.utc(2001)
      first = create :guess, person: guesser, commented_at: Time.utc(2000)
      Guess.first_by(guesser).should == first
    end

    it "ignores other players' guesses" do
      create :guess
      Guess.first_by(guesser).should be_nil
    end

  end

  describe '.most_recent_by' do
    let(:guesser) { create :person }

    it "returns the guesser's most recent guess" do
      create :guess, person: guesser, commented_at: Time.utc(2000)
      most_recent = create :guess, person: guesser, commented_at: Time.utc(2001)
      Guess.most_recent_by(guesser).should == most_recent
    end

    it "ignores other players' guesses" do
      create :guess
      Guess.most_recent_by(guesser).should be_nil
    end

  end

  describe '.oldest' do
    let(:guesser) { create :person }

    it "returns the guesser's guess made the longest after the post" do
      photo1 = create :photo, dateadded: Time.utc(2000)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      guess2 = create :guess, person: guesser, photo: photo2, commented_at: Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess2
      oldest.place.should == 1
    end

    it "ignores other players' guesses" do
      create :guess
      Guess.oldest(guesser).should be_nil
    end

    it "considers other players' guesses when calculating place" do
      photo1 = create :photo, dateadded: Time.utc(2000)
      guess1 = create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      create :guess, photo: photo2, commented_at: Time.utc(2004)
      oldest = Guess.oldest guesser
      oldest.should == guess1
      oldest.place.should == 2
    end

    it "ignores a guess that precedes its post" do
      photo1 = create :photo, dateadded: Time.utc(2001)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2000)
      Guess.oldest(guesser).should == nil
    end

  end

  describe '.longest_lasting' do
    let(:poster) { create :person }

    it "returns the poster's photo which went unfound the longest" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2000)
      create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, person: poster, dateadded: Time.utc(2002)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess2
      longest_lasting.place.should == 1
    end

    it "ignores guesses of other players' posts" do
      create :photo, person: poster
      create :guess
      Guess.longest_lasting(poster).should be_nil
    end

    it "considers other posters when calculating place" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2000)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2001)
      photo2 = create :photo, dateadded: Time.utc(2002)
      create :guess, photo: photo2, commented_at: Time.utc(2004)
      longest_lasting = Guess.longest_lasting poster
      longest_lasting.should == guess1
      longest_lasting.place.should == 2
    end

    it 'ignores a guess that precedes its post' do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2001)
      create :guess, photo: photo1, commented_at: Time.utc(2000)
      Guess.longest_lasting(poster).should == nil
    end

  end

  describe '.fastest' do
    let(:guesser) { create :person }

    it "returns the guesser's guess made the fastest after the post" do
      photo1 = create :photo, dateadded: Time.utc(2002)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      guess2 = create :guess, person: guesser, photo: photo2, commented_at: Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess2
      fastest.place.should == 1
    end

    it "ignores other players' guesses" do
      create :guess
      Guess.fastest(guesser).should be_nil
    end

    it "considers other players' guesses when calculating place" do
      photo1 = create :photo, dateadded: Time.utc(2002)
      guess1 = create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      create :guess, photo: photo2, commented_at: Time.utc(2001)
      fastest = Guess.fastest guesser
      fastest.should == guess1
      fastest.place.should == 2
    end

    it "ignores a guess that precedes its post" do
      photo1 = create :photo, dateadded: Time.utc(2001)
      create :guess, person: guesser, photo: photo1, commented_at: Time.utc(2000)
      Guess.fastest(guesser).should == nil
    end

  end

  describe '.shortest_lasting' do
    let(:poster) { create :person }

    it "returns the guess of the poster's photo which was made the soonest after the post" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2002)
      create :guess, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, person: poster, dateadded: Time.utc(2000)
      guess2 = create :guess, photo: photo2, commented_at: Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess2
      shortest_lasting.place.should == 1
    end

    it "ignores guesses of other players' posts" do
      create :photo, person: poster
      create :guess
      Guess.shortest_lasting(poster).should be_nil
    end

    it "considers other posters when calculating place" do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2002)
      guess1 = create :guess, photo: photo1, commented_at: Time.utc(2004)
      photo2 = create :photo, dateadded: Time.utc(2000)
      create :guess, photo: photo2, commented_at: Time.utc(2001)
      shortest_lasting = Guess.shortest_lasting poster
      shortest_lasting.should == guess1
      shortest_lasting.place.should == 2
    end

    it 'ignores a guess that precedes its post' do
      photo1 = create :photo, person: poster, dateadded: Time.utc(2001)
      create :guess, photo: photo1, commented_at: Time.utc(2000)
      Guess.shortest_lasting(poster).should == nil
    end

  end

  describe '.mapped_count' do
    it "counts the person's guesses of mapped photos" do
      photo = create :photo, accuracy: 12
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 1
    end

    it "counts the person's guesses of auto-mapped photos" do
      photo = create :photo, inferred_latitude: 37
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 1
    end

    it "ignores others' guesses" do
      photo = create :photo, accuracy: 12
      create :guess, photo: photo
      other_person = create :person
      Guess.mapped_count(other_person.id).should == 0
    end

    it "ignores guesses of unmapped photos" do
      photo = create :photo
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 0
    end

    it "ignores guesses of photos mapped with insufficient accuracy" do
      photo = create :photo, accuracy: 11
      guess = create :guess, photo: photo
      Guess.mapped_count(guess.person.id).should == 0
    end

  end

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

  describe '.all_between' do
    it 'returns all guesses between the given dates' do
      guess = create :guess, added_at: Time.utc(2011, 1, 1, 0, 0, 1)
      Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == [ guess ]
    end

    it 'ignores guesses made on or before the from date' do
      create :guess, added_at: Time.utc(2011)
      Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == []
    end

    it 'ignores guesses made after the to date' do
      create :guess, added_at: Time.utc(2011, 1, 1, 0, 0, 2)
      Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1)).should == []
    end

  end

  describe '.find_with_associations' do
    it "returns a person's guesses with their photos and the photos' people" do
      guess = create :guess
      guesses = Guess.find_with_associations guess.person
      guesses.should == [ guess ]
      guesses[0].photo.should == guess.photo
      guesses[0].photo.person.should == guess.photo.person
    end
  end

  describe '#years_old' do
    it 'returns the number of full years from post to guess (ignoring leap years)' do
      photo = Photo.new dateadded: Time.utc(2010)
      guess = Guess.new photo: photo, commented_at: Time.utc(2011)
      guess.years_old.should == 1
    end
  end

  describe '#seconds_old' do
    it 'returns the number of full seconds from post to guess' do
      photo = Photo.new dateadded: Time.utc(2010)
      guess = Guess.new photo: photo, commented_at: Time.utc(2010, 1, 1, 0, 0, 1)
      guess.seconds_old.should == 1
    end
  end

  describe '#time_elapsed' do
    it 'returns the duration in seconds from post to guess in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      guess = Guess.new photo: photo, commented_at: Time.utc(2001, 2, 2, 1, 1, 1)
      guess.time_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day, 1&nbsp;hour, 1&nbsp;minute, 1&nbsp;second';
    end
  end

  describe '#ymd_elapsed' do
    it 'returns the duration in days from post to guess in English' do
      photo = Photo.new dateadded: Time.utc(2000)
      guess = Guess.new photo: photo, commented_at: Time.utc(2001, 2, 2, 1, 1, 1)
      guess.ymd_elapsed.should == '1&nbsp;year, 1&nbsp;month, 1&nbsp;day';
    end
  end

  describe '#star_for_age' do
    expected = { 2000 => nil, 2001 => :bronze, 2002 => :silver, 2003 => :gold }
    expected.keys.sort.each do |year_guessed|
      it "returns a #{expected[year_guessed]} star for a #{year_guessed - 2000}-year-old guess" do
        photo = Photo.new dateadded: Time.utc(2000)
        guess = Guess.new photo: photo, commented_at: Time.utc(year_guessed)
        guess.star_for_age.should == expected[year_guessed]
      end
    end
  end

  describe '#star_for_speed' do
    expected = { 10 => :gold, 11 => :silver, 60 => :silver, 61 => nil }
    expected.keys.sort.each do |seconds_guessed|
      it "returns a #{expected[seconds_guessed]} star for a #{seconds_guessed}-second-old guess" do
        photo = Photo.new dateadded: Time.utc(2000)
        guess = Guess.new photo: photo, commented_at: Time.utc(2000) + seconds_guessed
        guess.star_for_speed.should == expected[seconds_guessed]
      end
    end
  end

end
