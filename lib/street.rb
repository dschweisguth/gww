class Street < Struct.new :name, :type

  SYNONYM = {
    'DEHARO' => 'DE HARO',
    'DIVIS' => 'DIVISADERO',
    "DUNNE'S" => 'DUNNES',
    "O'FARRELL" => 'OFARRELL',
    'SACTO' => 'SACRAMENTO'
  }

  def initialize(name, type=nil)
    sanitized_name = name.upcase
    super SYNONYM[sanitized_name] || sanitized_name, StreetType.get(type ? type.strip : nil)
  end

end
