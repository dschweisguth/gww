describe Color::Green do
  describe '#scaled_green' do
    it "starts at E0FCE0 (more or less DFFFDF)" do
      expect(Color::Green.scaled(0, 1, 0)).to eq('E0FCE0')
    end

    it "ends at 008000 (more or less 007F00)" do
      expect(Color::Green.scaled(0, 1, 1)).to eq('008000')
    end

    it "handles a single point" do
      expect(Color::Green.scaled(0, 0, 0)).to eq('008000')
    end

  end
end
