describe PrecalculatorJob::Job, type: :job do
  describe '#calculate_statistics_and_maps' do
    it "does some work" do
      expect(StatisticsPerson).to receive(:update_statistics)
      expect(StatisticsPhoto).to receive(:update_statistics)
      expect(StatisticsPhoto).to receive(:infer_geocodes)
      mock_clear_page_cache
      expect(described_class.run).to eq("Updated statistics and maps.")
    end
  end
end
