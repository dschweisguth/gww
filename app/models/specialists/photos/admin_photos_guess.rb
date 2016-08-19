class AdminPhotosGuess < Guess
  belongs_to :photo, inverse_of: :guesses, class_name: 'AdminPhotosPhoto', foreign_key: 'photo_id'
  belongs_to :person, inverse_of: :guesses, class_name: 'AdminPhotosPerson', foreign_key: 'person_id'
end
