module GWW
  module Helpers
    module PageCache
      def mock_clear_page_cache(times = 1)
        expect(::PageCache).to receive(:clear).exactly(times).times
      end
    end
  end
end
