module GWW
  module Helpers
    module PageCache
      def mock_clear_page_cache(times = 1)
        mock(::PageCache).clear.times(times)
      end
    end
  end
end
