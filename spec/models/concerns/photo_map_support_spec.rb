describe PhotoMapSupport do

  describe '#prepare_for_map' do
    it "copies the inferred geocode to the real one if necessary" do
      photo = build :photo, inferred_latitude: 1, inferred_longitude: 2
      photo.prepare_for_map 1.day.ago
      photo.latitude.should == 1
      photo.longitude.should == 2
    end

    it "leaves an existing real geocode alone" do
      photo = build :photo, latitude: 3, longitude: 4, inferred_latitude: 1, inferred_longitude: 2
      photo.prepare_for_map 1.day.ago
      photo.latitude.should == 3
      photo.longitude.should == 4
    end

    it "gives an unfound yellow and ?" do
      photo = build :photo
      photo.prepare_for_map 1.day.ago
      photo.color.should == Color::Yellow.scaled(0, 0, 0)
      photo.symbol.should == '?'
    end

    it "prepares an unconfirmed like an unfound" do
      photo = build :photo, game_status: 'unconfirmed'
      photo.prepare_for_map 1.day.ago
      photo.color.should == Color::Yellow.scaled(0, 0, 0)
      photo.symbol.should == '?'
    end

    it "gives a found green and !" do
      photo = build :photo, game_status: 'found'
      photo.prepare_for_map 1.day.ago
      photo.color.should == Color::Green.scaled(0, 1, 1)
      photo.symbol.should == '!'
    end

    it "gives a revealed red and -" do
      photo = build :photo, game_status: 'revealed'
      photo.prepare_for_map 1.day.ago
      photo.color.should == Color::Red.scaled(0, 1, 1)
      photo.symbol.should == '-'
    end

  end

end
