describe StreetType, type: :lib do
  describe '.get' do
    it "finds the type with the given name" do
      expect(StreetType.get('St')).to eq(StreetType.new('ST', true, [StreetType::Synonym.new('STREET', false)]))
    end

    it "ignores a trailing period" do
      expect(StreetType.get('St.')).to eq(StreetType.new('ST', true, [StreetType::Synonym.new('STREET', false)]))
    end

    it "finds the type with the given synonym" do
      expect(StreetType.get('Street')).to eq(StreetType.new('ST', true, [StreetType::Synonym.new('STREET', false)]))
    end

  end

  describe '.regexp' do
    it "matches a type" do
      expect(/^#{StreetType.regexp}/i).to match 'St'
    end

    it "includes a period in the match if the type is an abbreviation" do
      expect(/^#{StreetType.regexp}/i.match('St.')[0]).to eq('St.')
    end

    it "doesn't include a period in the match if the type isn't an abbreviation" do
      expect(/^#{StreetType.regexp}/i.match('Way.')[0]).to eq('Way')
    end

    it "doesn't match a type not on a word boundary" do
      expect(/^#{StreetType.regexp}/i).not_to match 'Stone'
    end

    it "matches a synonym" do
      expect(/^#{StreetType.regexp}/i).to match 'Street'
    end

    it "includes a period in the match if the synonym is an abbreviation" do
      expect(/^#{StreetType.regexp}/i.match('Wy.')[0]).to eq('Wy.')
    end

    it "doesn't include a period in the match if the synonym isn't an abbreviation" do
      expect(/^#{StreetType.regexp}/i.match('Street.')[0]).to eq('Street')
    end

    it "doesn't match a synonym not on a word boundary" do
      expect(/^#{StreetType.regexp}/i).not_to match 'Wyoming'
    end

  end

  describe '#to_s' do
    it "returns a nice string" do
      expect(StreetType.get('St').to_s).to eq('#<StreetType:ST>')
    end
  end

  describe '#inspect' do
    it "returns the same nice string as to_s" do
      type = StreetType.get('St')
      expect(type.inspect).to eq(type.to_s)
    end
  end

end
