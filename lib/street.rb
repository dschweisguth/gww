class Street < Struct.new :name, :type
  def initialize(name, type)
    super name, StreetType.get(type ? type.strip : nil)
  end
end
