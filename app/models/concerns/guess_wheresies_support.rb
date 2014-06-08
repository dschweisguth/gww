module GuessWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def longest_in(year)
     where("#{Guess::GUESS_AGE_IS_VALID} and ? < guesses.commented_at and guesses.commented_at < ?",
        Time.local(year).getutc, Time.local(year + 1).getutc)
        .order("#{Guess::GUESS_AGE} desc").limit(10).includes(:person, { photo: :person }).references :photos
    end

    def shortest_in(year)
      where("#{Guess::GUESS_AGE_IS_VALID} and ? < guesses.commented_at and guesses.commented_at < ?",
        Time.local(year).getutc, Time.local(year + 1).getutc)
        .order(Guess::GUESS_AGE).limit(10).includes(:person, { photo: :person }).references :photos
    end

  end

end
