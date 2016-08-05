class PeopleGuess < Guess
  belongs_to :photo, inverse_of: :guesses, class_name: 'PeoplePhoto', foreign_key: 'photo_id'
  belongs_to :person, inverse_of: :guesses, class_name: 'PeoplePerson', foreign_key: 'person_id'
end
