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
      photo.color.should == 'FFFF00'
      photo.symbol.should == '?'
    end

    it "prepares an unconfirmed like an unfound" do
      photo = build :photo, game_status: 'unconfirmed'
      photo.prepare_for_map 1.day.ago
      photo.color.should == 'FFFF00'
      photo.symbol.should == '?'
    end

    it "gives a found green and !" do
      photo = build :photo, game_status: 'found'
      photo.prepare_for_map 1.day.ago
      photo.color.should == photo.scaled_green(0, 1, 1)
      photo.symbol.should == '!'
    end

    it "gives a revealed red and -" do
      photo = build :photo, game_status: 'revealed'
      photo.prepare_for_map 1.day.ago
      photo.color.should == photo.scaled_red(0, 1, 1)
      photo.symbol.should == '-'
    end

  end

  context "when asking any photo for its colors" do
    let(:photo) { build :photo }

    describe '#scaled_red' do
      it "starts at FCC0C0 (more or less FFBFBF)" do
        photo.scaled_red(0, 1, 0).should == 'FCC0C0'
      end

      it "ends at E00000 (more or less DF0000)" do
        photo.scaled_red(0, 1, 1).should == 'E00000'
      end

      it "handles a single point" do
        photo.scaled_red(0, 0, 0).should == 'E00000'
      end

    end

    describe '#scaled_green' do
      it "starts at E0FCE0 (more or less DFFFDF)" do
        photo.scaled_green(0, 1, 0).should == 'E0FCE0'
      end

      it "ends at 008000 (more or less 007F00)" do
        photo.scaled_green(0, 1, 1).should == '008000'
      end

      it "handles a single point" do
        photo.scaled_green(0, 0, 0).should == '008000'
      end

    end

    describe '#scaled_blue' do
      it "starts at E0E0FC (more or less DFDFFF)" do
        photo.scaled_blue(0, 1, 0).should == 'E0E0FC'
      end

      it "ends at 0000FC" do
        photo.scaled_blue(0, 1, 1).should == '0000FC'
      end

      it "handles a single point" do
        photo.scaled_blue(0, 0, 0).should == '0000FC'
      end

    end

  end

end
