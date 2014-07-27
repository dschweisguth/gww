describe Color::Green do
  describe '#scaled_green' do
    it "starts at E0FCE0 (more or less DFFFDF)" do
      Color::Green.scaled(0, 1, 0).should == 'E0FCE0'
    end

    it "ends at 008000 (more or less 007F00)" do
      Color::Green.scaled(0, 1, 1).should == '008000'
    end

    it "handles a single point" do
      Color::Green.scaled(0, 0, 0).should == '008000'
    end

  end
end
