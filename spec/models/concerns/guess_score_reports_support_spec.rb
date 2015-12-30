describe GuessScoreReportsSupport do
  describe '.all_between' do
    it 'returns all guesses between the given dates' do
      guess = create :guess, added_at: Time.utc(2011, 1, 1, 0, 0, 1)
      expect(Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1))).to eq([ guess ])
    end

    it 'ignores guesses made on or before the from date' do
      create :guess, added_at: Time.utc(2011)
      expect(Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1))).to eq([])
    end

    it 'ignores guesses made after the to date' do
      create :guess, added_at: Time.utc(2011, 1, 1, 0, 0, 2)
      expect(Guess.all_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1))).to eq([])
    end

  end

  describe '#years_old' do
    it 'returns the number of full years from post to guess (ignoring leap years)' do
      photo = Photo.new dateadded: Time.utc(2010)
      guess = Guess.new photo: photo, commented_at: Time.utc(2011)
      expect(guess.years_old).to eq(1)
    end
  end

  describe '#seconds_old' do
    it 'returns the number of full seconds from post to guess' do
      photo = Photo.new dateadded: Time.utc(2010)
      guess = Guess.new photo: photo, commented_at: Time.utc(2010, 1, 1, 0, 0, 1)
      expect(guess.seconds_old).to eq(1)
    end
  end

  describe '#star_for_age' do
    expected = { 2000 => nil, 2001 => :bronze, 2002 => :silver, 2003 => :gold }
    expected.keys.sort.each do |year_guessed|
      it "returns a #{expected[year_guessed]} star for a #{year_guessed - 2000}-year-old guess" do
        photo = Photo.new dateadded: Time.utc(2000)
        guess = Guess.new photo: photo, commented_at: Time.utc(year_guessed)
        expect(guess.star_for_age).to eq(expected[year_guessed])
      end
    end
  end

  describe '#star_for_speed' do
    expected = { 10 => :gold, 11 => :silver, 60 => :silver, 61 => nil }
    expected.keys.sort.each do |seconds_guessed|
      it "returns a #{expected[seconds_guessed]} star for a #{seconds_guessed}-second-old guess" do
        photo = Photo.new dateadded: Time.utc(2000)
        guess = Guess.new photo: photo, commented_at: Time.utc(2000) + seconds_guessed
        expect(guess.star_for_speed).to eq(expected[seconds_guessed])
      end
    end
  end

end
