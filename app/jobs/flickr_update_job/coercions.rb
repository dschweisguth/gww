module FlickrUpdateJob
  module Coercions
    def to_float_or_nil(string)
      number = string.to_f
      number.zero? ? nil : number # Use .zero? to evade rubocop cop that claims to allow == 0 but doesn't
    end

    def to_integer_or_nil(string)
      number = string.to_i
      number == 0 ? nil : number
    end

    def to_string_or_nil(content)
      description = content.first
      description == {} ? nil : description
    end
  end
end
