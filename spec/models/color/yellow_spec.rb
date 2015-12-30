describe Color::Yellow do
  describe '#scaled' do
    it "starts at FCFC00" do
      expect(Color::Yellow.scaled(0, 1, 0)).to eq('FCFC00')
    end

    it "ends at FCFC00" do
      expect(Color::Yellow.scaled(0, 1, 1)).to eq('FCFC00')
    end

    it "handles a single point" do
      expect(Color::Yellow.scaled(0, 0, 0)).to eq('FCFC00')
    end

  end
end
