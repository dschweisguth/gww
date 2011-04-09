class Location < Struct.new :street1, :street2, :valid

  def self.make_valid(street1, street2)
    if ! street1
      raise ArgumentError, "street1 must not be nil"
    end
    if ! street2
      raise ArgumentError, "street2 must not be nil"
    end
    Location.new street1, street2, true
  end

  def self.make_invalid
    Location.new nil, nil, false
  end

end
