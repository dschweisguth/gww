module GWW
  module Helpers
    module PageCache
      def allow_clear_page_cache
        allow(::PageCache).to receive(:clear)
      end

      def expect_clear_page_cache(times = 1)
        expect(::PageCache).to have_received(:clear).exactly(times).times
      end

    end
  end
end
