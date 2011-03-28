require 'spec_helper'

describe Color do
  without_transactions

  before do
    self.extend Color
  end

  describe '#scaled_red' do
    it "starts at FCC0C0 (more or less FFBFBF)" do
      scaled_red(0, 1, 0).should == 'FCC0C0'
    end

    it "ends at E00000 (more or less DF0000)" do
      scaled_red(0, 1, 1).should == 'E00000'
    end

    it "handles a single point" do
      scaled_red(0, 0, 0).should == 'E00000'
    end

  end

  describe '#scaled_green' do
    it "starts at E0FCE0 (more or less DFFFDF)" do
      scaled_green(0, 1, 0).should == 'E0FCE0'
    end

    it "ends at 008000 (more or less 007F00)" do
      scaled_green(0, 1, 1).should == '008000'
    end

    it "handles a single point" do
      scaled_green(0, 0, 0).should == '008000'
    end

  end

  describe '#scaled_blue' do
    it "starts at E0E0FC (more or less DFDFFF)" do
      scaled_blue(0, 1, 0).should == 'E0E0FC'
    end

    it "ends at 0000FC" do
      scaled_blue(0, 1, 1).should == '0000FC'
    end

    it "handles a single point" do
      scaled_blue(0, 0, 0).should == '0000FC'
    end

  end

end
