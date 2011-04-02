require 'spec_helper'

describe PageCache do
  describe '#clear' do
    CACHE_DIR = Rails.root.to_s + "/public/cache"

    it 'deletes public/cache if it exists' do
      stub(File).exist?(CACHE_DIR) { true }
      mock(FileUtils).rm_r(CACHE_DIR)
      PageCache.clear
    end

    it "doesn't if it doesn't" do
      stub(File).exist?(CACHE_DIR) { false }
      dont_allow(FileUtils).rm_r
      PageCache.clear
    end

  end
end
