describe GuessPeopleSupport do
  describe '.find_with_associations' do
    it "returns a person's guesses with their photos and the photos' people" do
      guess = create :guess
      guesses = Guess.find_with_associations guess.person
      guesses.should == [ guess ]
      guesses[0].photo.should == guess.photo
      guesses[0].photo.person.should == guess.photo.person
    end
  end

end
