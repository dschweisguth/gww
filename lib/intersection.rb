class Intersection < Struct.new :text, :street1, :type1, :street2, :type2

  def initialize(text, street1, type1, street2, type2)
    super text, street1, trim(type1), street2, trim(type2)
  end

  def trim(type)
    type && ! type.empty? ? type.strip : nil
  end

end
