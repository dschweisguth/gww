module GuessWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def longest_in(year)
     with_valid_age
      .where("? < guesses.commented_at", Time.local(year).getutc)
      .where("guesses.commented_at < ?", Time.local(year + 1).getutc)
      .order_by_age(:desc).limit(10).includes(:person, { photo: :person })
    end

    def shortest_in(year)
      with_valid_age
        .where("? < guesses.commented_at", Time.local(year).getutc)
        .where("guesses.commented_at < ?", Time.local(year + 1).getutc)
        .order_by_age.limit(10).includes(:person, { photo: :person })
    end

  end

end
