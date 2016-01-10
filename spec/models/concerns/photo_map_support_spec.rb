describe PhotoMapSupport do

  describe '.mapped' do
    let(:bounds) { Bounds.new 0, 2, 3, 5 }

    it "returns photos" do
      photo = create :photo, latitude: 1, longitude: 4, accuracy: 12
      expect(Photo.mapped(bounds, 1)).to eq([photo])
    end

    it "returns auto-mapped photos" do
      photo = create :photo, inferred_latitude: 1, inferred_longitude: 4, accuracy: 12
      expect(Photo.mapped(bounds, 1)).to eq([photo])
    end

    it "ignores unmapped photos" do
      create :photo
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores mapped photos with accuracy < 12" do
      create :photo, latitude: 1, longitude: 4, accuracy: 11
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores mapped photos south of the minimum latitude" do
      create :photo, latitude: -1, longitude: 4, accuracy: 12
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores mapped photos north of the maximum latitude" do
      create :photo, latitude: 3, longitude: 4, accuracy: 12
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores mapped photos west of the minimum longitude" do
      create :photo, latitude: 1, longitude: 2, accuracy: 12
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores mapped photos east of the maximum longitude" do
      create :photo, latitude: 1, longitude: 6, accuracy: 12
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores auto-mapped photos south of the minimum latitude" do
      create :photo, inferred_latitude: -1, inferred_longitude: 4
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores auto-mapped photos north of the maximum latitude" do
      create :photo, inferred_latitude: 3, inferred_longitude: 4
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores auto-mapped photos west of the minimum longitude" do
      create :photo, inferred_latitude: 1, inferred_longitude: 2
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "ignores auto-mapped photos east of the maximum longitude" do
      create :photo, inferred_latitude: 1, inferred_longitude: 6
      expect(Photo.mapped(bounds, 1)).to eq([])
    end

    it "returns only the youngest n photos" do
      photo = create :photo, latitude: 1, longitude: 4, accuracy: 12
      create :photo, latitude: 1, longitude: 4, accuracy: 12, dateadded: 1.day.ago
      expect(Photo.mapped(bounds, 1)).to eq([photo])
    end

  end

  describe '.oldest' do
    it "returns the oldest photo" do
      create :photo
      photo = create :photo, dateadded: 1.day.ago
      expect(Photo.oldest).to eq(photo)
    end
  end

  describe '#prepare_for_map' do
    it "copies the inferred geocode to the real one if necessary" do
      photo = build :photo, inferred_latitude: 1, inferred_longitude: 2
      photo.prepare_for_map 1.day.ago
      expect(photo.latitude).to eq(1)
      expect(photo.longitude).to eq(2)
    end

    it "leaves an existing real geocode alone" do
      photo = build :photo, latitude: 3, longitude: 4, inferred_latitude: 1, inferred_longitude: 2
      photo.prepare_for_map 1.day.ago
      expect(photo.latitude).to eq(3)
      expect(photo.longitude).to eq(4)
    end

    it "gives an unfound yellow and ?" do
      photo = build :photo
      photo.prepare_for_map 1.day.ago
      expect(photo.color).to eq(Color::Yellow.scaled(0, 0, 0))
      expect(photo.symbol).to eq('?')
    end

    it "prepares an unconfirmed like an unfound" do
      photo = build :photo, game_status: 'unconfirmed'
      photo.prepare_for_map 1.day.ago
      expect(photo.color).to eq(Color::Yellow.scaled(0, 0, 0))
      expect(photo.symbol).to eq('?')
    end

    it "gives a found green and !" do
      photo = build :photo, game_status: 'found'
      photo.prepare_for_map 1.day.ago
      expect(photo.color).to eq(Color::Green.scaled(0, 1, 1))
      expect(photo.symbol).to eq('!')
    end

    it "gives a revealed red and -" do
      photo = build :photo, game_status: 'revealed'
      photo.prepare_for_map 1.day.ago
      expect(photo.color).to eq(Color::Red.scaled(0, 1, 1))
      expect(photo.symbol).to eq('-')
    end

  end

end
