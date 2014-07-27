describe Color::Blue do
  describe '#scaled_blue' do
    it "starts at E0E0FC (more or less DFDFFF)" do
      Color::Blue.scaled(0, 1, 0).should == 'E0E0FC'
    end

    it "ends at 0000FC" do
      Color::Blue.scaled(0, 1, 1).should == '0000FC'
    end

    it "handles a single point" do
      Color::Blue.scaled(0, 0, 0).should == '0000FC'
    end

  end
end
