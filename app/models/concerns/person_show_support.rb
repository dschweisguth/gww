module PersonShowSupport
  extend ActiveSupport::Concern

  def standing
    place = 1
    tied = false
    scores_by_person = Guess.group(:person_id).count
    people_by_score = scores_by_person.keys.group_by { |person_id| scores_by_person[person_id] }
    scores = people_by_score.keys.sort { |a, b| b <=> a }
    scores.each do |score|
      people_with_score = people_by_score[score]
      if people_with_score.include? id
        tied = people_with_score.length > 1
        break
      else
        place += people_with_score.length
      end
    end
    return place, tied
  end

  def posts_standing
    place = 1
    tied = false
    posts_by_person = Photo.group(:person_id).count
    people_by_post_count = posts_by_person.keys.group_by { |person_id| posts_by_person[person_id] }
    post_counts = people_by_post_count.keys.sort { |a, b| b <=> a }
    post_counts.each do |post_count|
      people_with_post_count = people_by_post_count[post_count]
      if people_with_post_count.include? id
        tied = people_with_post_count.length > 1
        break
      else
        place += people_with_post_count.length
      end
    end
    return place, tied
  end

  def first_guess
    guesses.includes(photo: :person).order(:commented_at).first
  end

  def most_recent_guess
    guesses.includes(photo: :person).order(:commented_at).last
  end

  def first_photo
    photos.order(:dateadded).includes(:person).first
  end

  def most_recent_photo
    photos.order(:dateadded).includes(:person).last
  end

  G_AGE = 'unix_timestamp(g.commented_at) - unix_timestamp(p.dateadded)'
  G_AGE_IS_VALID = 'unix_timestamp(g.commented_at) > unix_timestamp(p.dateadded)'

  def oldest_guess
    first_guess_with_place(:guesses, 'desc',
      "#{Guess::GUESS_AGE} > " +
        "(select max(#{G_AGE}) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id)")
  end

  def fastest_guess
    first_guess_with_place(:guesses, 'asc',
      "#{Guess::GUESS_AGE} < " +
        "(select min(#{G_AGE}) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id and #{G_AGE_IS_VALID})")
  end

  def guess_of_longest_lasting_post
    first_guess_with_place(:photos, 'desc',
      "#{Guess::GUESS_AGE} > " +
        "(select max(#{G_AGE}) from guesses g, photos p where g.photo_id = p.id and p.person_id = ?)")
  end

  def guess_of_shortest_lasting_post
    first_guess_with_place(:photos, 'asc',
      "#{Guess::GUESS_AGE} < " +
        "(select min(#{G_AGE}) from guesses g, photos p where g.photo_id = p.id and p.person_id = ? and #{G_AGE_IS_VALID})")
  end

  private def first_guess_with_place(owned_object, order, place_conditions)
    guess =
      Guess
        .includes(:person, { photo: :person })
        .where(owned_object => { person_id: self })
        .with_valid_age
        .order("#{Guess::GUESS_AGE} #{order}").first
    if ! guess
      return nil
    end
    guess.place = Guess.joins(:photo).where(place_conditions, self).with_valid_age.count + 1
    guess
  end

  def favorite_posters
    favorite_posters = Person.find_by_sql [
      %Q[
        select posters.*,
          count(*) / posters_posts.post_count /
            (select count(*) from guesses where person_id = ?) *
            (select count(*) from photos) bias
        from guesses g, photos f, people posters,
          (select person_id, count(*) post_count from photos
            group by person_id having count(*) >= #{Person::MIN_GUESSES_FOR_FAVORITE}) posters_posts
        where g.photo_id = f.id and
          g.person_id = ? and f.person_id = posters.id and
          f.person_id = posters_posts.person_id
        group by posters.id
        having count(*) >= #{Person::MIN_GUESSES_FOR_FAVORITE} and bias >= #{Person::MIN_BIAS_FOR_FAVORITE}
        order by bias desc
      ],
      id, id
    ]
    favorite_posters.each { |fp| fp.bias = fp[:bias] }
    favorite_posters
  end

  def favoring_guessers
    favoring_guessers = Person.find_by_sql [
      %Q[
        select guessers.*,
          count(*) / (select count(*) from photos where person_id = ?) /
            guessers_guesses.guess_count * (select count(*) from photos) bias
        from guesses g, photos f, people guessers,
          (select person_id, count(*) guess_count from guesses
            group by person_id) guessers_guesses
        where g.photo_id = f.id and
          g.person_id = guessers.id and f.person_id = ? and
          g.person_id = guessers_guesses.person_id
        group by guessers.id
        having count(*) >= #{Person::MIN_GUESSES_FOR_FAVORITE} and bias >= #{Person::MIN_BIAS_FOR_FAVORITE}
        order by bias desc
      ],
      id, id
    ]
    favoring_guessers.each { |fp| fp.bias = fp[:bias] }
    favoring_guessers
  end

  def unfound_photos
    photos.where game_status: %w(unfound unconfirmed)
  end

  def revealed_photos
    photos.where(game_status: 'revealed').includes(:tags)
  end

end
