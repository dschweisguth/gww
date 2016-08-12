class StatisticsGuess < Guess
  belongs_to :photo, inverse_of: :guesses, class_name: 'StatisticsPhoto', foreign_key: 'photo_id'
  belongs_to :person, inverse_of: :guesses, class_name: 'StatisticsPerson', foreign_key: 'person_id'
end
