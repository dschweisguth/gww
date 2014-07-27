describe MultiPhotoMapSupport do
  describe '#perturb_identical_locations' do
    it "moves younger photos so that they don't completely overlap older photos with identical locations" do
      photos = build_list :photo, 3, latitude: 37, longitude: -122
      Photo.perturb_identical_locations photos
      # Increasingly younger photos are moved farther along the involute of a circle
      photos[0].latitude.should be_within(0.000001).of 36.999951
      photos[0].longitude.should be_within(0.000001).of -122.000003
      photos[1].latitude.should be_within(0.000001).of 36.999991
      photos[1].longitude.should be_within(0.000001).of -122.000037
      photos[2].latitude.should == 37
      photos[2].longitude.should == -122
    end
  end
end
