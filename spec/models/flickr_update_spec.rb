describe FlickrUpdate do

  describe '#member_count' do
    it { is_expected.to validate_numericality_of(:member_count).is_greater_than_or_equal_to(0) }
    it { is_expected.to have_readonly_attribute :member_count }
  end

  describe '.latest' do
    it "returns the most recent update" do
      create :flickr_update
      most_recent_update = create :flickr_update
      expect(FlickrUpdate.latest).to eq(most_recent_update)
    end
  end

end
