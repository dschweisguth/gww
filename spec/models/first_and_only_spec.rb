describe ActiveRecord::Base do
  describe '.first_and_only' do
    it "returns the only instance of the object of the class that the method is called on" do
      allow(Person).to receive(:all) { [1] }
      expect(Person.first_and_only).to eq(1)
    end

    it "fails the example if there is a number of objects of that class other than 1" do
      allow(Person).to receive(:all) { [1, 2] }
      expect { Person.first_and_only }.to raise_error(
        RSpec::Expectations::ExpectationNotMetError, "Expected there to be only 1 Person instance, but there are 2")
    end

  end
end
