class Street < Struct.new :name, :type

  CANONICAL_TYPE = {
    'STREET' => 'ST'
  }

  def initialize(name, type)
    super name, type && ! type.empty? ? type.strip : nil
  end

  def canonical_type
    sanitized_type = type.chomp('.').upcase
    canonical_type = CANONICAL_TYPE[sanitized_type]
    canonical_type ? canonical_type : sanitized_type
  end

end
