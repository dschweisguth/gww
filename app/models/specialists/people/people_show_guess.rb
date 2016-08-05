class PeopleShowGuess < Guess
  include GuessScoreSupport

  belongs_to :photo, inverse_of: :guesses, class_name: 'PeopleShowPhoto', foreign_key: 'photo_id'
  belongs_to :person, inverse_of: :guesses, class_name: 'PeopleShowPerson', foreign_key: 'person_id'

end
