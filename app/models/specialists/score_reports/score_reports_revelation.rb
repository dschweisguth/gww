class ScoreReportsRevelation < Revelation
  belongs_to :photo, inverse_of: :guesses, class_name: 'ScoreReportsPhoto', foreign_key: 'photo_id'

  # Not persisted, used in views
  attr_accessor :change_in_standing

end
