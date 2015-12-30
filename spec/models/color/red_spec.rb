describe Color::Red do
  describe '#scaled' do
    it "starts at FCC0C0 (more or less FFBFBF)" do
      expect(Color::Red.scaled(0, 1, 0)).to eq('FCC0C0')
    end

    it "ends at E00000 (more or less DF0000)" do
      expect(Color::Red.scaled(0, 1, 1)).to eq('E00000')
    end

    it "handles a single point" do
      expect(Color::Red.scaled(0, 0, 0)).to eq('E00000')
    end

  end
end
