class AdminPhotosRevelation < Revelation
  belongs_to :photo, inverse_of: :guesses, class_name: 'AdminPhotosPhoto', foreign_key: 'photo_id'
end
