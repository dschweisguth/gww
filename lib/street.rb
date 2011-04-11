class Street < Struct.new :name, :type

  def initialize(name, type)
    super name, (type && ! type.empty? ? type.strip : nil)
  end

end
