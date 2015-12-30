describe PhotoAdminRootSupport do
  describe '.unfound_or_unconfirmed_count' do
    %w(unfound unconfirmed).each do |game_status|
      it "counts #{game_status} photos" do
        create :photo, game_status: game_status
        expect(Photo.unfound_or_unconfirmed_count).to eq(1)
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        create :photo, game_status: game_status
        expect(Photo.unfound_or_unconfirmed_count).to eq(0)
      end
    end

  end

  describe '.inaccessible_count' do
    before do
      create :flickr_update, created_at: Time.utc(2014)
    end

    it "counts photos which have not been seen since the last Flickr update" do
      create :photo, seen_at: Time.utc(2013)
      expect(Photo.inaccessible_count).to eq(1)
    end

    it "counts unconfirmed photos" do
      create :photo, seen_at: Time.utc(2013), game_status: 'unconfirmed'
      expect(Photo.inaccessible_count).to eq(1)
    end

    it "ignores a photo which has been seen since the last Flickr update" do
      create :photo, seen_at: Time.utc(2014)
      expect(Photo.inaccessible_count).to eq(0)
    end

    %w(found revealed).each do |game_status|
      it "ignores a #{game_status} photo which has not been seen since the last Flickr update" do
        create :photo, seen_at: Time.utc(2013), game_status: game_status
        expect(Photo.inaccessible_count).to eq(0)
      end
    end

  end

  describe '.multipoint_count' do
    let(:photo) { create :photo }

    it "counts photos with more than one guess" do
      photo = create :photo
      create_list :guess, 2, photo: photo
      expect(Photo.multipoint_count).to eq(1)
    end

    it "ignores a photo with only one guess" do
      create :guess, photo: photo
      expect(Photo.multipoint_count).to eq(0)
    end

  end

end
