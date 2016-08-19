class AdminPhotosPerson < Person
  has_many :photos, inverse_of: :person, class_name: 'AdminPhotosPhoto', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :person, class_name: 'AdminPhotosGuess', foreign_key: 'person_id'
end
