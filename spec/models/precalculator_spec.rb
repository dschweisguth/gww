describe Precalculator do
  describe '#calculate_statistics_and_maps' do
    it "does some work" do
      expect(Person).to receive(:update_statistics)
      expect(Photo).to receive(:update_statistics)
      expect(Photo).to receive(:infer_geocodes)
      mock_clear_page_cache
      expect(Precalculator.calculate_statistics_and_maps).to eq("Updated statistics and maps.")
    end
  end
end
