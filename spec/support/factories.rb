module GWW
  module Factories
    module Model
      delegate :build, :create, :create_list, to: FactoryGirl
    end

    module ControllerOrHelper
      delegate :build_stubbed, to: FactoryGirl
    end

  end
end
