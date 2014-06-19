module GWW
  module Factories
    module Base
      DELEGATE = Class.new.include(FactoryGirl::Syntax::Methods).new

      def delegate_to_factory_girl(methods)
        methods.each do |name|
          define_method name do |*args|
            DELEGATE.send name, *args
          end
        end
      end

    end

    module Model
      extend Base
      delegate_to_factory_girl %i(build create create_list)
    end

    # Also appropriate for view helpers
    module Controller
      extend Base
      delegate_to_factory_girl %i(build_stubbed)
    end

  end
end
