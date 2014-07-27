describe Color::Yellow do
  describe '#scaled' do
    it "starts at FCFC00" do
      Color::Yellow.scaled(0, 1, 0).should == 'FCFC00'
    end

    it "ends at FCFC00" do
      Color::Yellow.scaled(0, 1, 1).should == 'FCFC00'
    end

    it "handles a single point" do
      Color::Yellow.scaled(0, 0, 0).should == 'FCFC00'
    end

  end
end
