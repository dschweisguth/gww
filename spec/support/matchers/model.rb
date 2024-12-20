module GWW
  module Matchers
    module Model
      def have_attributes?(expected)
        HaveAttributes.new expected
      end

      class HaveAttributes
        def initialize(expected)
          @expected = expected.transform_keys(&:to_s)
        end

        def matches?(subject)
          @actual = subject.attributes
          @expected.all? { |name, value| @actual[name] == value }
        end

        def failure_message
          missing_attr_names = @expected.keys - @actual.keys
          "expected attributes to be a superset of #{@expected}, but " +
            if missing_attr_names.any?
              "#{missing_attr_names} #{missing_attr_names.size == 1 ? 'was' : 'were'} missing"
            else
              "they included #{@expected.reject { |name, value| @actual[name] == value }.to_h { |name, _| [name, @actual[name]] }}"
            end
        end

      end

      def have_the_same_attributes_as?(expected)
        HaveTheSameAttributesAs.new expected
      end

      class HaveTheSameAttributesAs
        def initialize(expected)
          @expected = expected.attributes
        end

        def only(*attr_names)
          @attr_names = attr_names.map &:to_s
          self
        end

        def matches?(subject)
          @actual = subject.attributes
          @attr_names ||= @expected.keys
          @actual.values_at(*@attr_names) == @expected.values_at(*@attr_names)
        end

        def failure_message
          "expected #{names_and_values @expected}, but got #{names_and_values @actual}"
        end

        def names_and_values(object)
          @attr_names.to_h { |name| [name, object[name]] }
        end

      end

    end
  end
end
