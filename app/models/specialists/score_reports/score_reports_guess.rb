class ScoreReportsGuess < Guess
  include GuessScoreSupport

  belongs_to :photo, inverse_of: :guesses, class_name: 'ScoreReportsPhoto', foreign_key: 'photo_id'
  belongs_to :person, inverse_of: :guesses, class_name: 'ScoreReportsPerson', foreign_key: 'person_id'

  def self.all_between(from, to)
    where("? < added_at", from.getutc).where("added_at <= ?", to.getutc).
      order(:commented_at).includes(:person, photo: :person)
  end

end
