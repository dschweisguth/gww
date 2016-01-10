describe PhotoScoreReportsSupport do
  describe '.count_between' do
    it 'counts all photos between the given dates' do
      create :photo, dateadded: Time.utc(2011, 1, 1, 0, 0, 1)
      expect(Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1))).to eq(1)
    end

    it 'ignores photos made on or before the from date' do
      create :photo, dateadded: Time.utc(2011)
      expect(Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1))).to eq(0)
    end

    it 'ignores photos made after the to date' do
      create :photo, dateadded: Time.utc(2011, 1, 1, 0, 0, 2)
      expect(Photo.count_between(Time.utc(2011), Time.utc(2011, 1, 1, 0, 0, 1))).to eq(0)
    end

  end

  describe '.unfound_or_unconfirmed_count_before' do
    it "counts photos added on or before and not scored on or before the given date" do
      create :photo, dateadded: Time.utc(2011)
      expect(Photo.unfound_or_unconfirmed_count_before(Time.utc(2011))).to eq(1)
    end

    it "includes photos guessed after the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, added_at: Time.utc(2011, 2)
      expect(Photo.unfound_or_unconfirmed_count_before(Time.utc(2011))).to eq(1)
    end

    it "includes photos revealed after the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :revelation, photo: photo, added_at: Time.utc(2011, 2)
      expect(Photo.unfound_or_unconfirmed_count_before(Time.utc(2011))).to eq(1)
    end

    it "ignores photos added after the given date" do
      create :photo, dateadded: Time.utc(2011, 2)
      expect(Photo.unfound_or_unconfirmed_count_before(Time.utc(2011))).to eq(0)
    end

    it "ignores photos guessed on or before the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :guess, photo: photo, added_at: Time.utc(2011)
      expect(Photo.unfound_or_unconfirmed_count_before(Time.utc(2011))).to eq(0)
    end

    it "ignores photos revealed on or before the given date" do
      photo = create :photo, dateadded: Time.utc(2011)
      create :revelation, photo: photo, added_at: Time.utc(2011)
      expect(Photo.unfound_or_unconfirmed_count_before(Time.utc(2011))).to eq(0)
    end

  end

  describe '.add_posts' do
    let(:person) { create :person }

    it "adds each person's posts as an attribute" do
      create :photo, person: person, dateadded: Time.utc(2010)
      Photo.add_posts [person], Time.utc(2011), :post_count
      expect(person.post_count).to eq(1)
    end

    it "ignores posts made after the report date" do
      create :photo, person: person, dateadded: Time.utc(2011)
      Photo.add_posts [person], Time.utc(2010), :post_count
      expect(person.post_count).to eq(0)
    end

  end

  describe '#years_old' do
    it "returns 0 for a photo posted moments ago" do
      expect(create(:photo, dateadded: Time.now).years_old).to eq(0)
    end

    it "returns 1 for a photo posted moments + 1 year ago" do
      expect(create(:photo, dateadded: Time.now - 1.years).years_old).to eq(1)
    end

  end

  describe '#star_for_age' do
    now = Time.now
    expected = { 0 => nil, 1 => :bronze, 2 => :silver, 3 => :gold }
    expected.keys.sort.each do |years_old|
      it "returns a #{expected[years_old]} star for a #{years_old}-year-old photo" do
        photo = Photo.new dateadded: now - years_old.years
        expect(photo.star_for_age).to eq(expected[years_old])
      end
    end
  end

end
