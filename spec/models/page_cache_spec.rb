describe PageCache do
  describe '#clear' do
    CACHE_DIR = Rails.root.to_s + "/public/cache"

    it "deletes public/cache if it exists" do
      allow(File).to receive(:exist?).with(CACHE_DIR).and_return(true)
      allow(FileUtils).to receive(:rm_r).with(CACHE_DIR)
      PageCache.clear
      expect(FileUtils).to have_received(:rm_r)
    end

    it "doesn't if it doesn't" do
      allow(File).to receive(:exist?).with(CACHE_DIR).and_return(false)
      allow(FileUtils).to receive(:rm_r)
      PageCache.clear
      expect(FileUtils).not_to have_received(:rm_r)
    end

  end
end
