describe PrecalculatorJob::Job, type: :job do
  describe '#calculate_statistics_and_maps' do
    it "does some work" do
      allow(StatisticsPerson).to receive(:update_statistics)
      allow(StatisticsPhoto).to receive(:update_statistics)
      allow(StatisticsPhoto).to receive(:infer_geocodes)
      allow_clear_page_cache
      message = described_class.run

      expect(message).to eq("Updated statistics and maps.")
      expect(StatisticsPerson).to have_received(:update_statistics)
      expect(StatisticsPhoto).to have_received(:update_statistics)
      expect(StatisticsPhoto).to have_received(:infer_geocodes)
      expect_clear_page_cache
    end
  end
end
