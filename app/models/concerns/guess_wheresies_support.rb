module GuessWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def longest_in(year)
      longest_or_shortest_in year, :desc
    end

    def shortest_in(year)
      longest_or_shortest_in year, :asc
    end

    private def longest_or_shortest_in(year, direction)
      with_valid_age
        .where("? < guesses.commented_at", Time.local(year).getutc)
        .where("guesses.commented_at < ?", Time.local(year + 1).getutc)
        .order_by_age(direction).limit(10).includes(:person, { photo: :person })
    end

  end

end
