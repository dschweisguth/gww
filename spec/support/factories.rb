module GWW
  module Factories
    module Model
      delegate :build, :build_list, :create, :create_list, to: FactoryBot
    end

    module ControllerOrHelper
      delegate :build_stubbed, to: FactoryBot
    end

  end
end
