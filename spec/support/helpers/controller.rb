module GWW
  module Helpers
    module Controller
      def top_node
        Capybara.string response.body
      end
    end
  end
end
