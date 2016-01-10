class Address < Struct.new :text, :number, :street, :at, :between1, :between2

  def initialize(text, number, street_name, street_type,
      near1_name = nil, near1_type = nil, near2_name = nil, near2_type = nil)
    if ! near1_name && near2_name
      raise ArgumentError, "near1_name must be non-nil if near2_name is non-nil, but " \
        "near1_name was nil and near2_name was #{near2_name}"
    end
    near1 = near1_name ? Street.new(near1_name, near1_type) : nil
    near2 = near2_name ? Street.new(near2_name, near2_type) : nil
    if near1 && ! near2
      super text, number, Street.new(street_name, street_type), near1, nil, nil
    else
      super text, number, Street.new(street_name, street_type), nil, near1, near2
    end
  end

  # TODO this ignores the possibility that the between streets will disambiguate a missing street type
  def will_have_same_geocode_as(other)
    other.is_a?(Address) && other.number == number && other.street == street
  end

end
