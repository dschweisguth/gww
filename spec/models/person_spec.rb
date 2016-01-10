describe Person do
  describe '#flickrid' do
    it { does validate_presence_of :flickrid }
    it { does have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { does validate_presence_of :username }

    it "handles non-ASCII characters" do
      non_ascii_username = '猫娘/ nekomusume'
      create :person, username: non_ascii_username
      expect(Person.all[0].username).to eq(non_ascii_username)
    end

  end

  describe '#destroy_if_has_no_dependents' do
    let(:person) { create :person }

    it "destroys the person" do
      person.destroy_if_has_no_dependents
      expect(Person.count).to eq(0)
    end

    it "but not if they have a photo" do
      create :photo, person: person
      person.destroy_if_has_no_dependents
      expect(Person.all).to eq([person])
    end

    it "but not if they have a guess" do
      create :guess, person: person
      person.destroy_if_has_no_dependents
      expect(Person.find(person.id)).to eq(person)
    end

  end

end
