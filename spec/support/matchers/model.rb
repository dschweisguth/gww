module GWW
  module Matchers
    module Model
      
      def validate_non_negative_integer(attr)
        ValidateNonNegativeInteger.new(attr)
      end

      class ValidateNonNegativeInteger < Shoulda::Matchers::ActiveRecord::ValidationMatcher
        def matches?(subject)
          super(subject)
          disallows_value_of('abcd', :not_a_number) &&
            disallows_value_of(-1, "must be greater than or equal to 0") &&
            disallows_value_of(0.1, 'must be an integer')
        end

        def description
          "only allow non-negative integer for #{@attribute}"
        end

      end

    end
  end
end
