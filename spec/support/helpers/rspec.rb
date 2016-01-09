module GWW
  module Helpers
    module RSpec
      def does(*args)
        is_expected.to *args
      end
    end
  end
end
