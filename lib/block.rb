class Block < Struct.new :text, :street, :type, :between1, :between1_type, :between2, :between2_type
  def initialize(text, street, type, between1, between1_type, between2, between2_type)
    super text, street, trim(type), between1, trim(between1_type), between2, trim(between2_type)
  end

  def trim(type)
    type && ! type.empty? ? type.strip : nil
  end

end
