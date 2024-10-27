Block = Struct.new :text, :on, :between1, :between2 do
  include TwoStreets

  def initialize(text, on_name, on_type, between1_name, between1_type, between2_name, between2_type)
    super text, Street.new(on_name, on_type),
      Street.new(between1_name, between1_type), Street.new(between2_name, between2_type)
  end

  def will_have_same_geocode_as(other)
    other.is_a?(Block) && other.on == on && equal_ignoring_order?(other.between1, other.between2, between1, between2)
  end

end
