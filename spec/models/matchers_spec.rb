describe '#have_attributes' do
  let(:person) { build :person }

  it "passes if the subject has the given attributes" do
    person.should have_attributes(flickrid: person.flickrid)
  end

  it "handles more than one attribute" do
    person.should have_attributes(flickrid: person.flickrid, username: person.username)
  end

  it "fails if an attribute is missing" do
    lambda { person.should have_attributes(unknown: 'unknown') }.should raise_error(
      RSpec::Expectations::ExpectationNotMetError,
      %q(expected attributes to be a superset of {"unknown"=>"unknown"}, but ["unknown"] was missing))
  end

  it "fails if an attribute is different" do
    lambda { person.should have_attributes(flickrid: nil) }.should raise_error(
      RSpec::Expectations::ExpectationNotMetError,
      %Q(expected attributes to be a superset of {"flickrid"=>nil}, but they included {"flickrid"=>"#{person.flickrid}"}))
  end

end

describe '#have_the_same_attributes_as' do
  class Attributed
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

  end

  it "passes if the subject and standard have all the same attributes" do
    subject = Attributed.new attr1: 'value1'
    standard = Attributed.new attr1: 'value1'
    subject.should have_the_same_attributes_as(standard)
  end

  it "fails if an attribute is different" do
    subject = Attributed.new attr1: 'value1'
    standard = Attributed.new attr1: 'value2'
    lambda { subject.should have_the_same_attributes_as(standard) }.should raise_error(
      RSpec::Expectations::ExpectationNotMetError,
      %q(expected {:attr1=>"value2"}, but got {:attr1=>"value1"}))
  end

  it "checks a subset of attributes" do
    subject = Attributed.new attr1: 'value1', attr2: 'value2'
    standard = Attributed.new attr1: 'value1', attr2: 'value3'
    subject.should have_the_same_attributes_as(standard).only(:attr1)
  end

end
