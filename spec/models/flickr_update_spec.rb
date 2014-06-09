describe FlickrUpdate do

  describe '#member_count' do
    it { should validate_presence_of :member_count }
    it { should validate_non_negative_integer :member_count }
    it { should have_readonly_attribute :member_count }
  end

  describe '.latest' do
    it "returns the most recent update" do
      create :flickr_update
      most_recent_update = create :flickr_update
      FlickrUpdate.latest.should == most_recent_update
    end
  end

end
