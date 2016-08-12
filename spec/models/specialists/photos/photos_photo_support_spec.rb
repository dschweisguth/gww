describe PhotosPhoto do
  describe '.unfound_or_unconfirmed' do
    %w(unfound unconfirmed).each do |game_status|
      it "returns #{game_status} photos" do
        photo = create :photos_photo, game_status: game_status
        expect(PhotosPhoto.unfound_or_unconfirmed).to eq([photo])
      end
    end

    %w(found revealed).each do |game_status|
      it "ignores #{game_status} photos" do
        create :photos_photo, game_status: game_status
        expect(PhotosPhoto.unfound_or_unconfirmed).to eq([])
      end
    end

  end

  describe '#human_tags' do
    let(:photo) { create :photos_photo }

    it "returns non-machine tags sorted by id" do
      photo.tags.create! raw: 'Tag 2'
      photo.tags.create! raw: 'Tag 1'
      expect(photo.human_tags.map(&:raw)).to eq(['Tag 2', 'Tag 1'])
    end

    it "ignores machine tags" do
      photo.tags.create! raw: 'Machine tag 1', machine_tag: true
      expect(photo.human_tags).to be_empty
    end

  end

  describe '#machine_tags' do
    let(:photo) { create :photos_photo }

    it "returns machine tags sorted by id" do
      photo.tags.create! raw: 'Tag 2', machine_tag: true
      photo.tags.create! raw: 'Tag 1', machine_tag: true
      expect(photo.machine_tags.map(&:raw)).to eq(['Tag 2', 'Tag 1'])
    end

    it "ignores machine tags" do
      photo.tags.create! raw: 'Machine tag 1', machine_tag: false
      expect(photo.machine_tags).to be_empty
    end

  end

end
