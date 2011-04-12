class Address < Struct.new :text, :number, :street, :between1, :between2

  def initialize(text, number, street_name, street_type,
      between1_name = nil, between1_type = nil, between2_name = nil, between2_type = nil)
    if between1_name.nil? ^ between2_name.nil?
      raise ArgumentError, "between1_name and between2_name must both be nil or non-nil, but " +
        "between1_name == #{between1_name} and between2_name == #{between2_name}"
    end
    between1, between2 = between1_name.nil? ? [ nil, nil ] : \
      [ Street.new(between1_name, between1_type), Street.new(between2_name, between2_type) ]
    super text, number, Street.new(street_name, street_type), between1, between2
  end

end
