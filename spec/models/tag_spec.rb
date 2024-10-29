describe Tag do
  describe '#raw' do
    it { does validate_presence_of :raw }
    it { does have_readonly_attribute :raw }

    it "is unique for a given photo" do
      existing = create :tag, raw: 'text'
      expect(build(:tag, photo: existing.photo, raw: 'text')).not_to be_valid
    end

    it "is not unique across photos" do
      create :tag, raw: 'text'
      expect(build(:tag, raw: 'text')).to be_valid
    end

  end

  describe '#machine_tag' do
    # Can't use validate_presence_of because that validation happens before the database default value is applied
    it { does have_readonly_attribute :machine_tag }

    it "defaults to false" do
      expect(Tag.new(raw: 'text').machine_tag).to be(false)
    end

    [false, true].each do |boolean|
      it "may be #{boolean}" do
        expect(Tag.new(raw: 'text', machine_tag: boolean)).to be_valid
      end
    end

    # shoulda-matchers' validate_inclusion_of doesn't test this
    it "may not be nil" do
      expect(Tag.new(raw: 'text', machine_tag: nil)).not_to be_valid
    end

    # There does not seem to be a way to set machine_tag to a non-nil non-boolean

  end

  describe '#correct?' do
    context "when checking foundinSF" do
      it "returns true if the photo is found" do
        photo = build :photo, game_status: 'found'
        tag = build :tag, photo: photo, raw: 'foundinSF'
        expect(tag.correct?).to be_truthy
      end

      it "returns false if the photo is not found" do
        photo = build :photo, game_status: 'unfound'
        tag = build :tag, photo: photo, raw: 'foundinSF'
        expect(tag.correct?).to be_falsy
      end

      it "is case-insensitive" do
        photo = build :photo, game_status: 'unfound'
        tag = build :tag, photo: photo, raw: 'FOUNDINSF'
        expect(tag.correct?).to be_falsy
      end

    end

    context "when checking unfoundinSF" do
      %w(unfound unconfirmed).each do |game_status|
        it "returns true if the photo is #{game_status}" do
          photo = build :photo, game_status: game_status
          tag = build :tag, photo: photo, raw: 'unfoundinSF'
          expect(tag.correct?).to be_truthy
        end
      end

      %w(found revealed).each do |game_status|
        it "returns false if the photo is #{game_status}" do
          photo = build :photo, game_status: game_status
          tag = build :tag, photo: photo, raw: 'unfoundinSF'
          expect(tag.correct?).to be_falsy
        end
      end

      it "is case-insensitive" do
        photo = build :photo, game_status: 'found'
        tag = build :tag, photo: photo, raw: 'UNFOUNDINSF'
        expect(tag.correct?).to be_falsy
      end

    end

    context "when checking revealedinSF" do
      it "returns true if the photo is revealed" do
        photo = build :photo, game_status: 'revealed'
        tag = build :tag, photo: photo, raw: 'revealedinSF'
        expect(tag.correct?).to be_truthy
      end

      it "returns false if the photo is not revealed" do
        photo = build :photo, game_status: 'unfound'
        tag = build :tag, photo: photo, raw: 'revealedinSF'
        expect(tag.correct?).to be_falsy
      end

      it "is case-insensitive" do
        photo = build :photo, game_status: 'unfound'
        tag = build :tag, photo: photo, raw: 'REVEALEDINSF'
        expect(tag.correct?).to be_falsy
      end

    end

  end

end
