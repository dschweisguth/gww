class Intersection < Struct.new :text, :at1, :at2
  include TwoStreets

  def initialize(text, at1_name, at1_type, at2_name, at2_type)
    super text, Street.new(at1_name, at1_type), Street.new(at2_name, at2_type)
  end

  def will_have_same_geocode_as(other)
    other.is_a?(Intersection) && equal_ignoring_order?(other.at1, other.at2, at1, at2)
  end

end
