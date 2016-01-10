describe Street, type: :lib do
  describe '.regexp' do
    it "accepts any whitespace in a multiword name" do
      matches 'CHARLES J BRENHAM', "Charles \n J \n Brenham"
    end

    %w( Saint St St. ).each do |title|
      it "accepts #{title} as an abbreviation for Saint" do
        matches 'SAINT FRANCIS', "#{title} Francis"
      end
    end

    %w( J J. ).each do |initial|
      it "accepts #{initial} as a middle initial" do
        matches 'CHARLES J BRENHAM', "Charles #{initial} Brenham"
      end
    end

    [' Jr', ', Jr', ' Junior', ', Junior'].each do |title|
      it "accepts '#{title}' as a way of writing Junior" do
        matches 'COLIN P KELLY JR', "Colin P Kelly#{title}"
      end
    end

    def matches(known, text)
      expect(Regexp.new(Street.regexp(known), Regexp::IGNORECASE)).to match text
    end

  end

  describe '#initialize' do
    it "upcases the name" do
      expect(Street.new('Valencia').name).to eq('VALENCIA')
    end

    it "converts each run of whitespace in the name to a single space" do
      expect(Street.new("Willard \n North").name).to eq('WILLARD NORTH')
    end

    it "removes punctuation from and upcases the name" do
      expect(Street.new("John F. O'Kennedy, Jr.").name).to eq('JOHN F OKENNEDY JR')
    end

    it "converts ST to SAINT" do
      expect(Street.new('St Francis').name).to eq('SAINT FRANCIS')
    end

    it "converts JUNIOR to JR" do
      expect(Street.new('MARTIN LUTHER KING JUNIOR').name).to eq('MARTIN LUTHER KING JR')
    end

    it "doesn't clobber Junior (Terrace)" do
      expect(Street.new('JUNIOR').name).to eq('JUNIOR')
    end

    it "canonicalizes a synonym" do
      expect(Street.new('DeHaro').name).to eq('DE HARO')
    end

    it "converts a string street type to a real one" do
      expect(Street.new('Valencia', 'St').type).to eq(StreetType.get('St'))
    end

    it "ignores whitespace around the input street type" do
      expect(Street.new('Valencia', ' St ').type).to eq(StreetType.get('St'))
    end

  end

end
