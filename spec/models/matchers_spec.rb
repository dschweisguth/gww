describe GWW::Matchers::Model do
  describe '#have_attributes?' do
    let(:person) { build :person }

    it "passes if the subject has the given attributes" do
      expect(person).to have_attributes?(flickrid: person.flickrid)
    end

    it "handles more than one attribute" do
      expect(person).to have_attributes?(flickrid: person.flickrid, username: person.username)
    end

    it "fails if an attribute is missing" do
      expect { expect(person).to have_attributes?(unknown: 'unknown') }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        %q(expected attributes to be a superset of {"unknown"=>"unknown"}, but ["unknown"] was missing))
    end

    it "fails grammatically if multiple attributes are missing" do
      expect { expect(person).to have_attributes?(unknown1: 'unknown1', unknown2: 'unknown2') }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        %q(expected attributes to be a superset of {"unknown1"=>"unknown1", "unknown2"=>"unknown2"}, ) +
          %q(but ["unknown1", "unknown2"] were missing))
    end

    it "fails if an attribute is different" do
      expect { expect(person).to have_attributes?(flickrid: nil) }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        %Q(expected attributes to be a superset of {"flickrid"=>nil}, but they included {"flickrid"=>"#{person.flickrid}"}))
    end

  end

  describe '#have_the_same_attributes_as?' do
    class Attributed
      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes
      end

    end

    it "passes if the subject and standard have all the same attributes" do
      subject = Attributed.new attr1: 'value1'
      standard = Attributed.new attr1: 'value1'
      expect(subject).to have_the_same_attributes_as?(standard)
    end

    it "fails if an attribute is different" do
      subject = Attributed.new attr1: 'value1'
      standard = Attributed.new attr1: 'value2'
      expect { expect(subject).to have_the_same_attributes_as?(standard) }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError,
        %q(expected {:attr1=>"value2"}, but got {:attr1=>"value1"}))
    end

    it "checks a subset of attributes" do
      subject = Attributed.new attr1: 'value1', attr2: 'value2'
      standard = Attributed.new attr1: 'value1', attr2: 'value3'
      expect(subject).to have_the_same_attributes_as?(standard).only(:attr1)
    end

  end

end
