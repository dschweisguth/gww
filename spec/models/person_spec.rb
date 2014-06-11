describe Person do

  describe '#flickrid' do
    it { should validate_presence_of :flickrid }
    it { should have_readonly_attribute :flickrid }
  end

  describe '#username' do
    it { should validate_presence_of :username }

    it 'should handle non-ASCII characters' do
      non_ascii_username = '猫娘/ nekomusume'
      create :person, username: non_ascii_username
      Person.all[0].username.should == non_ascii_username
    end

  end

  describe '#destroy_if_has_no_dependents' do
    let(:person) { create :person }

    it 'destroys the person' do
      person.destroy_if_has_no_dependents
      Person.count.should == 0
    end

    it 'but not if they have a photo' do
      create :photo, person: person
      person.destroy_if_has_no_dependents
      Person.all.should == [ person ]
    end

    it 'but not if they have a guess' do
      create :guess, person: person
      person.destroy_if_has_no_dependents
      Person.find(person.id).should == person
    end

  end

end
