describe PageCache do
  describe '#clear' do
    CACHE_DIR = Rails.root.to_s + "/public/cache"

    it "deletes public/cache if it exists" do
      allow(File).to receive(:exist?).with(CACHE_DIR) { true }
      expect(FileUtils).to receive(:rm_r).with(CACHE_DIR)
      PageCache.clear
    end

    it "doesn't if it doesn't" do
      allow(File).to receive(:exist?).with(CACHE_DIR) { false }
      expect(FileUtils).not_to receive(:rm_r)
      PageCache.clear
    end

  end
end
