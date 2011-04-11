class Street < Struct.new :name, :type

  CANONICAL_TYPE = {
    'STREET' => 'ST'
  }

  def initialize(name, type)
    super name, (type && ! type.empty? ? type.strip : nil)
  end

  def canonical_type
    canonical_type = CANONICAL_TYPE[type.upcase]
    canonical_type ? canonical_type : type
  end

end
