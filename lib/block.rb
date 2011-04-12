class Block < Struct.new :text, :on, :between1, :between2
  def initialize(text, on_name, on_type, between1_name, between1_type, between2_name, between2_type)
    super text, Street.new(on_name, on_type),
      Street.new(between1_name, between1_type), Street.new(between2_name, between2_type)
  end
end
