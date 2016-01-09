module GWW
  module Helpers
    module Routing
      def does(*args)
        is_expected.to *args
      end

      def has_named_route(*args)
        is_expected.to have_named_route(*args)
      end

    end
  end
end
