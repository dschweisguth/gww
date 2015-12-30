describe Color::Blue do
  describe '#scaled_blue' do
    it "starts at E0E0FC (more or less DFDFFF)" do
      expect(Color::Blue.scaled(0, 1, 0)).to eq('E0E0FC')
    end

    it "ends at 0000FC" do
      expect(Color::Blue.scaled(0, 1, 1)).to eq('0000FC')
    end

    it "handles a single point" do
      expect(Color::Blue.scaled(0, 0, 0)).to eq('0000FC')
    end

  end
end
