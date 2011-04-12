class Intersection < Struct.new :text, :at1, :at2
  def initialize(text, at1_name, at1_type, at2_name, at2_type)
    super text, Street.new(at1_name, at1_type), Street.new(at2_name, at2_type)
  end
end
