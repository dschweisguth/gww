describe PhotoPeopleShowSupport do
  describe '#has_obsolete_tags?' do
    %w(found revealed).each do |game_status|
      it "returns true if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_truthy
      end
    end

    it "is case-insensitive" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'UNFOUNDINSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    %w(unfound unconfirmed).each do |game_status|
      it "returns false if a #{game_status} photo is tagged unfoundinSF" do
        photo = create :photo, game_status: game_status
        create :tag, photo: photo, raw: 'unfoundinSF'
        photo.has_obsolete_tags?.should be_falsy
      end
    end

    it "returns false if a found photo is tagged something else" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unseeninSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a found photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns true if a found photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'found'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_truthy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and foundinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'foundinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

    it "returns false if a revealed photo is tagged both unfoundinSF and revealedinSF" do
      photo = create :photo, game_status: 'revealed'
      create :tag, photo: photo, raw: 'unfoundinSF'
      create :tag, photo: photo, raw: 'revealedinSF'
      photo.has_obsolete_tags?.should be_falsy
    end

  end

end
