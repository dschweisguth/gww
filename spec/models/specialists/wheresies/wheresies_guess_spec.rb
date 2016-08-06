describe WheresiesGuess do
  describe '.longest_in' do
    it "lists guesses made in the given year sorted by time between post and guess, descending" do
      photo1 = create :wheresies_photo, dateadded: Time.local(2010).getutc
      guess1 = create :wheresies_guess, photo: photo1, commented_at: Time.local(2010, 2).getutc
      photo2 = create :wheresies_photo, dateadded: Time.local(2010).getutc
      guess2 = create :wheresies_guess, photo: photo2, commented_at: Time.local(2010, 3).getutc
      expect(WheresiesGuess.longest_in(2010)).to eq([guess2, guess1])
    end

    it "ignores a guess made before it was posted" do
      photo = create :wheresies_photo, dateadded: Time.local(2010, 2).getutc
      create :wheresies_guess, photo: photo, commented_at: Time.local(2010).getutc
      expect(WheresiesGuess.longest_in(2010)).to eq([])
    end

  end

  describe '.shortest_in' do
    it "lists guesses made in the given year sorted by time between post and guess, ascending" do
      photo1 = create :wheresies_photo, dateadded: Time.local(2010).getutc
      guess1 = create :wheresies_guess, photo: photo1, commented_at: Time.local(2010, 3).getutc
      photo2 = create :wheresies_photo, dateadded: Time.local(2010).getutc
      guess2 = create :wheresies_guess, photo: photo2, commented_at: Time.local(2010, 2).getutc
      expect(WheresiesGuess.shortest_in(2010)).to eq([guess2, guess1])
    end

    it "ignores a guess made before it was posted" do
      photo = create :wheresies_photo, dateadded: Time.local(2010, 2).getutc
      create :wheresies_guess, photo: photo, commented_at: Time.local(2010).getutc
      expect(WheresiesGuess.shortest_in(2010)).to eq([])
    end

  end

end
