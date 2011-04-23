require 'spec_helper'

describe MapSupport do

  before do
    self.extend MapSupport
  end

  describe '#thin' do
    it "thins out photos in dense areas of the map" do
      bounds = PhotosController::INITIAL_MAP_BOUNDS
      photo1 = Photo.make :id => 1, :latitude => bounds.min_lat, :longitude => bounds.min_long, :dateadded => 1.day.ago
      photo2 = Photo.make :id => 2, :latitude => bounds.min_lat, :longitude => bounds.min_long, :dateadded => 2.days.ago
      stub(self).too_many { 0 }
      stub(self).photos_per_bin { 1 }
      thin([ photo1, photo2 ], bounds, 20).should == [ photo1 ]
    end

    it "does nothing if the number of photos is below a threshold" do
      bounds = PhotosController::INITIAL_MAP_BOUNDS
      photo1 = Photo.make :id => 1, :latitude => bounds.min_lat, :longitude => bounds.min_long, :dateadded => 1.day.ago
      photo2 = Photo.make :id => 2, :latitude => bounds.min_lat, :longitude => bounds.min_long, :dateadded => 2.days.ago
      stub(self).too_many { 2 }
      stub(self).photos_per_bin { 1 }
      thin([ photo1, photo2 ], bounds, 20).should == [ photo1, photo2 ]
    end

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
