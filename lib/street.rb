class Street < Struct.new :name, :type

  CANONICAL_TYPE = {
    'ALLEY' => 'ALY',
    'AVENUE' => 'AVE',
    'BOULEVARD' => 'BLVD',
    'CIRCLE' => 'CIR',
    'COURT' => 'CT',
    'DRIVE' => 'DR',
    'EXPRESSWAY' => 'EXPY',
    'HILL' => 'HL',
    'HIGHWAY' => 'HWY',
    'LANE' => 'LN',
    'PLACE' => 'PL',
    'PLAZA' => 'PLZ',
    'ROAD' => 'RD',
    'STEPS' => 'STPS',
    'STAIRS' => 'STWY',
    'STAIRWAY' => 'STWY',
    'STREET' => 'ST',
    'TERRACE' => 'TER',
    'TUNNEL' => 'TUNL',
    'WY' => 'WAY'
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
