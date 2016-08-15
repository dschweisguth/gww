class WheresiesGuess < Guess
  belongs_to :photo, inverse_of: :guesses, class_name: 'WheresiesPhoto', foreign_key: 'photo_id'
  belongs_to :person, inverse_of: :guesses, class_name: 'WheresiesPerson', foreign_key: 'person_id'

  def self.longest_in(year)
    longest_or_shortest_in year, :desc
  end

  def self.shortest_in(year)
    longest_or_shortest_in year, :asc
  end

  private_class_method def self.longest_or_shortest_in(year, direction)
    with_valid_age.
      where("? < guesses.commented_at", Time.local(year).getutc).
      where("guesses.commented_at < ?", Time.local(year + 1).getutc).
      order_by_age(direction).limit(10).includes(:person, photo: :person)
  end

end
