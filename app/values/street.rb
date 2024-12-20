Street = Struct.new :name, :type do
  self::SYNONYM = {
    '1' => '1ST',
    '2' => '2ND',
    '3' => '3RD',
    '4' => '4TH',
    '5' => '5TH',
    '6' => '6TH',
    '7' => '7TH',
    '8' => '8TH',
    '9' => '9TH',
    '10' => '10TH',
    '11' => '11TH',
    '12' => '12TH',
    '13' => '13TH',
    '14' => '14TH',
    '15' => '15TH',
    '16' => '16TH',
    '17' => '17TH',
    '18' => '18TH',
    '19' => '19TH',
    '20' => '20TH',
    '21' => '21ST',
    '22' => '22ND',
    '23' => '23RD',
    '24' => '24TH',
    '25' => '25TH',
    '26' => '26TH',
    '27' => '27TH',
    '28' => '28TH',
    '29' => '29TH',
    '30' => '30TH',
    '31' => '31ST',
    '32' => '32ND',
    '33' => '33RD',
    '34' => '34TH',
    '35' => '35TH',
    '36' => '36TH',
    '37' => '37TH',
    '38' => '38TH',
    '39' => '39TH',
    '40' => '40TH',
    '41' => '41ST',
    '42' => '42ND',
    '43' => '43RD',
    '44' => '44TH',
    '45' => '45TH',
    '47' => '47TH',
    '48' => '48TH',
    'ADELAIDE' => 'ISADORA DUNCAN',
    'ADLER' => 'JACK KEROUAC',
    'ALDRICH' => 'AMBROSE BIERCE',
    'DEHARO' => 'DE HARO',
    'DIRK DIRKSEN' => 'ROWLAND',
    'DIVIS' => 'DIVISADERO',
    'GRANDVIEW' => 'GRAND VIEW',
    'GROVER' => 'VIA BUFANO',
    'HARWOOD' => 'BOB KAUFMAN',
    'JFK' => 'JOHN F KENNEDY',
    'MONROE' => 'DASHIELL HAMMETT',
    'PARDEE' => 'JACK MICHELINE',
    'PFLUEGER' => 'CHELSEA',
    'MLK' => 'MARTIN LUTHER KING JR',
    'S VAN NESS' => 'SOUTH VAN NESS',
    'SACTO' => 'SACRAMENTO',
    'SGT JOHN V YOUNG' => 'SERGEANT JOHN V YOUNG',
    'SO VAN NESS' => 'SOUTH VAN NESS',
    'TIMOTHY PFLUEGER' => 'CHELSEA',
    'TRACY' => 'KENNETH REXROTH',
    'VERMEHR' => 'VER MEHR'
  }.freeze

  def self.regexp(multiword_street_name)
    multiword_street_name.
      gsub(/\bSAINT\b/, '(?:SAINT|ST\.?)').
      gsub(/([A-Za-z0-9']+\s+[A-Za-z0-9'])(\s+[A-Za-z0-9']+)/, '\1\.?\2').
      gsub(/(\s+)JR$/, ',?\1(?:JR\.?|JUNIOR)').
      gsub(/\s+/, '\s+')
  end

  def initialize(name, type = nil)
    sanitized_name = name.upcase.
      gsub(/\s+/, ' ').
      gsub(/['.,]/, '').
      sub(/^ST\b/, 'SAINT').
      sub(/ JUNIOR$/, ' JR')
    super self.class::SYNONYM[sanitized_name] || sanitized_name, StreetType.get(type&.strip)
  end

end
