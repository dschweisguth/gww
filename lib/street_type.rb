class StreetType < Struct.new :name, :is_abbr, :synonyms

  class Synonym < Struct.new :name, :is_abbr
  end

  INSTANCES = [
    ['ALY',  true, ['ALLEY', false]],
    ['AVE',  true, ['AVENUE', false]],
    ['BLVD', true, ['BOULEVARD', false]],
    ['CIR',  true, ['CIRCLE', false]],
    ['CT',   true, ['COURT', false]],
    ['DR',   true, ['DRIVE', false]],
    ['EXPY', true, ['EXPRESSWAY', false]],
    ['HL',   true, ['HILL', false]],
    ['HWY',  true, ['HIGHWAY', false]],
    ['LN',   true, ['LANE', false]],
    ['LOOP', false ],
    ['PARK', false ],
    ['PATH', false ],
    ['PL',   true, ['PLACE', false]],
    ['PLZ',  true, ['PLAZA', false]],
    ['RAMP', false ],
    ['RD',   true, ['ROAD', false]],
    ['ROW',  false ],
    ['ST',   true, ['STREET', false]],
    ['STPS', true, ['STEPS', false]],
    ['STWY', true, ['STAIRS', false], ['STAIRWAY', false]],
    ['TER',  true, ['TERRACE', false]],
    ['TUNL', true, ['TUNNEL', false]],
    ['WALK', false ],
    ['WAY',  false,['WY', true]]
  ].map { |name, is_abbr, *synonyms| new name, is_abbr, synonyms.map { |args| Synonym.new *args } }

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

  def to_s
    "#<StreetType:#{name}>"
  end

  def inspect
    to_s
  end

end
