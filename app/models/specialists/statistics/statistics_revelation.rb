class StatisticsRevelation < Revelation
  belongs_to :photo, inverse_of: :guesses, class_name: 'StatisticsPhoto', foreign_key: 'photo_id'
end
