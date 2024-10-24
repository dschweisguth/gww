describe WheresiesPerson do
  describe '.most_points_in' do
    it "returns a list of scorers with their scores" do
      guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
      top_scorers = WheresiesPerson.most_points_in 2010
      expect(top_scorers).to eq([guess.person])
      expect(top_scorers[0].points).to eq(1)
    end

    it "ignores guesses made before the given year" do
      create :wheresies_guess, commented_at: Time.local(2009).getutc
      expect(WheresiesPerson.most_points_in(2010)).to eq([])
    end

    it "ignores guesses made after the given year" do
      create :wheresies_guess, commented_at: Time.local(2011).getutc
      expect(WheresiesPerson.most_points_in(2010)).to eq([])
    end

    it "returns only the top 10 scorers" do
      10.times do
        guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
        create :wheresies_guess, person: guess.person, commented_at: Time.local(2010).getutc
      end
      single_guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
      top_scorers = WheresiesPerson.most_points_in 2010
      expect(top_scorers.length).to eq(10)
      expect(top_scorers).not_to include(single_guess.person)
    end

  end

  describe '.most_posts_in' do
    it "returns a lists of posters with their number of posts" do
      post = create :wheresies_photo, dateadded: Time.local(2010).getutc
      top_posters = WheresiesPerson.most_posts_in 2010
      expect(top_posters).to eq([post.person])
      expect(top_posters[0].post_count).to eq(1)
    end

    it "ignores posts before the given year" do
      create :wheresies_photo, dateadded: Time.local(2009).getutc
      expect(WheresiesPerson.most_posts_in(2010)).to eq([])
    end

    it "ignores posts after the given year" do
      create :wheresies_photo, dateadded: Time.local(2011).getutc
      expect(WheresiesPerson.most_posts_in(2010)).to eq([])
    end

    it "returns only the top 10 posters" do
      10.times do
        post = create :wheresies_photo, dateadded: Time.local(2010).getutc
        create :wheresies_photo, person: post.person, dateadded: Time.local(2010).getutc
      end
      single_post = create :wheresies_photo, dateadded: Time.local(2010).getutc
      top_posters = WheresiesPerson.most_posts_in 2010
      expect(top_posters.length).to eq(10)
      expect(top_posters).not_to include(single_post.person)
    end

  end

  describe '.rookies_with_most_points_in' do
    it "returns a list of rookies with their score" do
      guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
      top_scorers = WheresiesPerson.rookies_with_most_points_in 2010
      expect(top_scorers).to eq([guess.person])
      expect(top_scorers[0].points).to eq(1)
    end

    it "ignores people who guessed before the given year" do
      create :wheresies_guess, commented_at: Time.local(2009).getutc
      expect(WheresiesPerson.rookies_with_most_points_in(2010)).to eq([])
    end

    it "ignores people who guessed for the first time in the given year but posted for the first time before the given year" do
      guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
      create :wheresies_photo, person: guess.person, dateadded: Time.local(2009).getutc
      expect(WheresiesPerson.rookies_with_most_points_in(2010)).to eq([])
    end

    it "ignores guesses made after the given year" do
      create :wheresies_guess, commented_at: Time.local(2011).getutc
      expect(WheresiesPerson.rookies_with_most_points_in(2010)).to eq([])
    end

    it "ignores people who posted for the first time in the given year but guessed for the first time after the given year" do
      post = create :wheresies_photo, dateadded: Time.local(2010).getutc
      create :wheresies_guess, person: post.person, commented_at: Time.local(2011).getutc
      expect(WheresiesPerson.rookies_with_most_points_in(2010)).to eq([])
    end

    it "returns only the top 10 rookie scorers" do
      10.times do
        guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
        create :wheresies_guess, person: guess.person, commented_at: Time.local(2010).getutc
      end
      single_guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
      top_scorers = WheresiesPerson.rookies_with_most_points_in 2010
      expect(top_scorers.size).to eq(10)
      expect(top_scorers).not_to include(single_guess.person)
    end

  end

  describe '.rookies_with_most_posts_in' do
    it "returns a list of rookies with their number of posts" do
      post = create :wheresies_photo, dateadded: Time.local(2010).getutc
      top_posters = WheresiesPerson.rookies_with_most_posts_in 2010
      expect(top_posters).to eq([post.person])
      expect(top_posters[0].post_count).to eq(1)
    end

    it "ignores people who posted before the given year" do
      create :wheresies_photo, dateadded: Time.local(2009).getutc
      expect(WheresiesPerson.rookies_with_most_posts_in(2010)).to eq([])
    end

    it "ignores people who posted for the first time in the given year but guessed for the first time before the given year" do
      post = create :wheresies_photo, dateadded: Time.local(2010).getutc
      create :wheresies_guess, person: post.person, commented_at: Time.local(2009).getutc
      expect(WheresiesPerson.rookies_with_most_posts_in(2010)).to eq([])
    end

    it "ignores posts made after the given year" do
      create :wheresies_photo, dateadded: Time.local(2011).getutc
      expect(WheresiesPerson.rookies_with_most_posts_in(2010)).to eq([])
    end

    it "ignores people who guessed for the first time in the given year but posted for the first time after the given year" do
      guess = create :wheresies_guess, commented_at: Time.local(2010).getutc
      create :wheresies_photo, person: guess.person, dateadded: Time.local(2011).getutc
      expect(WheresiesPerson.rookies_with_most_posts_in(2010)).to eq([])
    end

    it "returns only the top 10 rookie posters" do
      10.times do
        post = create :wheresies_photo, dateadded: Time.local(2010).getutc
        create :wheresies_photo, person: post.person, dateadded: Time.local(2010).getutc
      end
      single_post = create :wheresies_photo, dateadded: Time.local(2010).getutc
      top_posters = WheresiesPerson.rookies_with_most_posts_in 2010
      expect(top_posters.size).to eq(10)
      expect(top_posters).not_to include(single_post.person)
    end

  end

end
