module GuessPeopleSupport
  extend ActiveSupport::Concern

  module ClassMethods
    G_AGE = 'unix_timestamp(g.commented_at) - unix_timestamp(p.dateadded)'
    G_AGE_IS_VALID = 'unix_timestamp(g.commented_at) > unix_timestamp(p.dateadded)'

    def first_by(guesser)
      includes(photo: :person).where(person_id: guesser).order(:commented_at).first
    end

    def most_recent_by(guesser)
      includes(photo: :person).where(person_id: guesser).order(:commented_at).last
    end

    def oldest(guesser)
      first_guess_with_place guesser, 'guesses.person_id = ?', 'desc',
        "#{Guess::GUESS_AGE} > (select max(#{G_AGE}) from guesses g, photos p " +
  	      'where g.person_id = ? and g.photo_id = p.id )'
    end

    def longest_lasting(poster)
      first_guess_with_place poster, 'photos.person_id = ?', 'desc',
        "#{Guess::GUESS_AGE} > (select max(#{G_AGE}) from guesses g, photos p " +
  	      'where g.photo_id = p.id and p.person_id = ?)'
    end

    def fastest(guesser)
      first_guess_with_place guesser, 'guesses.person_id = ?', 'asc',
        "#{Guess::GUESS_AGE} < (select min(#{G_AGE}) from guesses g, photos p " +
  	      "where g.person_id = ? and g.photo_id = p.id and #{G_AGE_IS_VALID})"
    end

    def shortest_lasting(poster)
      first_guess_with_place poster, 'photos.person_id = ?', 'asc',
        "#{Guess::GUESS_AGE} < (select min(#{G_AGE}) from guesses g, photos p " +
  	      "where g.photo_id = p.id and p.person_id = ? and #{G_AGE_IS_VALID})"
    end

    private def first_guess_with_place(person, conditions, order, place_conditions)
      guess = includes(:person, { photo: :person })
        .where("#{conditions} and #{Guess::GUESS_AGE_IS_VALID}", person).references(:photos).order("#{Guess::GUESS_AGE} #{order}").first
      if ! guess
        return nil
      end
      guess.place = joins(:photo).where("#{place_conditions} and #{Guess::GUESS_AGE_IS_VALID}", person.id).count + 1
      guess
    end

    def mapped_count(person_id)
      where(person_id: person_id)
        .joins(:photo).where('photos.accuracy >= 12 || photos.inferred_latitude is not null')
        .count
    end
  
  end

end
