class Address < Struct.new :text, :number, :street
  def initialize(text, number, street_name, street_type)
    super text, number, Street.new(street_name, street_type)
  end
end
