describe PeopleShowPhoto do
  describe '#ymd_elapsed' do
    it "returns the age with a precision of days in English" do
      photo = described_class.new dateadded: Time.utc(2000)
      allow(Time).to receive(:now) { Time.utc(2001, 2, 2, 1, 1, 1) }
      expect(photo.ymd_elapsed).to eq('1&nbsp;year, 1&nbsp;month, 1&nbsp;day')
    end
  end

  describe '#star_for_comments' do
    expected = { 0 => nil, 20 => :silver, 30 => :gold }
    expected.keys.sort.each do |other_user_comments|
      it "returns a #{expected[other_user_comments]} star for a photo with #{other_user_comments} comments" do
        photo = described_class.new other_user_comments: other_user_comments
        expect(photo.star_for_comments).to eq(expected[other_user_comments])
      end
    end
  end

  describe '#star_for_views' do
    expected = { 0 => nil, 300 => :bronze, 1000 => :silver, 3000 => :gold }
    expected.keys.sort.each do |views|
      it "returns a #{expected[views]} star for a photo with #{views} views" do
        photo = described_class.new views: views
        expect(photo.star_for_views).to eq(expected[views])
      end
    end
  end

  describe '#star_for_faves' do
    expected = { 0 => nil, 10 => :bronze, 30 => :silver, 100 => :gold }
    expected.keys.sort.each do |faves|
      it "returns a #{expected[faves]} star for a photo with #{faves} faves" do
        photo = described_class.new faves: faves
        expect(photo.star_for_faves).to eq(expected[faves])
      end
    end
  end

  describe '#obsolete_tags?' do
    %w(found revealed).each do |game_status|
      it "returns true if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :people_show_photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        expect(photo.obsolete_tags?).to be_truthy
      end
    end

    it "is case-insensitive" do
      photo = create :people_show_photo, game_status: 'found'
      create :tag, photo: photo, raw: 'UNFOUNDINSF'
      expect(photo.obsolete_tags?).to be_truthy
    end

    %w(unfound unconfirmed).each do |game_status|
      it "returns false if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :people_show_photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        expect(photo.obsolete_tags?).to be_falsy
      end
    end

    it "returns false if a found photo is tagged something else" do
      photo = create :people_show_photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unseeninSF'
      expect(photo.obsolete_tags?).to be_falsy
    end

    it "returns false if a found photo is tagged both unfoundinSF and foundinSF" do
      photo = create :people_show_photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      expect(photo.obsolete_tags?).to be_falsy
    end

    it "returns true if a found photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :people_show_photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      expect(photo.obsolete_tags?).to be_truthy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and foundinSF" do
      photo = create :people_show_photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      expect(photo.obsolete_tags?).to be_falsy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :people_show_photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      expect(photo.obsolete_tags?).to be_falsy
    end

  end

end
