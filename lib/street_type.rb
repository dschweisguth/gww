class StreetType < Struct.new :name, :is_abbr, :synonyms

  class Synonym < Struct.new :name, :is_abbr
  end

  INSTANCES = [
    new('ALY',  true,   [ Synonym.new('ALLEY', false) ]),
    new('AVE',  true,   [ Synonym.new('AVENUE', false) ]),
    new('BLVD', true,   [ Synonym.new('BOULEVARD', false) ]),
    new('CIR',  true,   [ Synonym.new('CIRCLE', false) ]),
    new('CT',   true,   [ Synonym.new('COURT', false) ]),
    new('DR',   true,   [ Synonym.new('DRIVE', false) ]),
    new('EXPY', true,   [ Synonym.new('EXPRESSWAY', false) ]),
    new('HL',   true,   [ Synonym.new('HILL', false) ]),
    new('HWY',  true,   [ Synonym.new('HIGHWAY', false) ]),
    new('LN',   true,   [ Synonym.new('LANE', false) ]),
    new('LOOP', false,  []),
    new('PARK', false,  []),
    new('PATH', false,  []),
    new('PL',   true,   [ Synonym.new('PLACE', false) ]),
    new('PLZ',  true,   [ Synonym.new('PLAZA', false) ]),
    new('RAMP', false,  []),
    new('RD',   true,   [ Synonym.new('ROAD', false) ]),
    new('ROW',  false,  []),
    new('ST',   true,   [ Synonym.new('STREET', false) ]),
    new('STPS', true,   [ Synonym.new('STEPS', false) ]),
    new('STWY', true,   [ Synonym.new('STAIRS', false), Synonym.new('STAIRWAY', false) ]),
    new('TER',  true,   [ Synonym.new('TERRACE', false) ]),
    new('TUNL', true,   [ Synonym.new('TUNNEL', false) ]),
    new('WALK', false,  []),
    new('WAY',  false,  [ Synonym.new('WY', true) ])
  ]

  def self.get(name)
    if ! name
      return nil
    end
    sanitized_name = name.chomp('.').upcase
    INSTANCES.find { |type| type.name == sanitized_name ||
      type.synonyms.find { |synonym| synonym.name == sanitized_name } }
  end

  def self.regexp
    INSTANCES.each_with_object('') do |type, regexp|
      add_name regexp, type
      type.synonyms.each { |synonym| add_name regexp, synonym }
    end
  end

  def self.add_name(regexp, type)
    regexp << '|' if ! regexp.empty?
    regexp << type.name
    regexp << '\b'
    regexp << '\.?' if type.is_abbr
  end

end
