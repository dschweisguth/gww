module PersonShowSupport
  extend ActiveSupport::Concern

  def mapped_photo_count
    photos.where('accuracy >= 12 or inferred_latitude is not null').count
  end

  def mapped_guess_count
    guesses.joins(:photo).where('photos.accuracy >= 12 || photos.inferred_latitude is not null').count
  end

  def score_standing
    standing Guess
  end

  def posts_standing
    standing Photo
  end

  private def standing(achievement_type)
    place = 1
    tied = false
    achievements_by_person = achievement_type.group(:person_id).count
    people_by_achievement_count = achievements_by_person.keys.group_by { |person_id| achievements_by_person[person_id] }
    achievement_counts = people_by_achievement_count.keys.sort { |a, b| b <=> a }
    achievement_counts.each do |achievement_count|
      people_with_achievement_count = people_by_achievement_count[achievement_count]
      if people_with_achievement_count.include? id
        tied = people_with_achievement_count.length > 1
        break
      else
        place += people_with_achievement_count.length
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
    first_guess_with_place(:guesses, :desc,
      "#{Guess::GUESS_AGE} > " +
        "(select max(#{G_AGE}) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id)")
  end

  def fastest_guess
    first_guess_with_place(:guesses, :asc,
      "#{Guess::GUESS_AGE} < " +
        "(select min(#{G_AGE}) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id and #{G_AGE_IS_VALID})")
  end

  def guess_of_longest_lasting_post
    first_guess_with_place(:photos, :desc,
      "#{Guess::GUESS_AGE} > " +
        "(select max(#{G_AGE}) from guesses g, photos p where g.photo_id = p.id and p.person_id = ?)")
  end

  def guess_of_shortest_lasting_post
    first_guess_with_place(:photos, :asc,
      "#{Guess::GUESS_AGE} < " +
        "(select min(#{G_AGE}) from guesses g, photos p where g.photo_id = p.id and p.person_id = ? and #{G_AGE_IS_VALID})")
  end

  private def first_guess_with_place(owned_object, order, place_conditions)
    guess =
      Guess.
        includes(:person, photo: :person).
        where(owned_object => { person_id: self }).
        with_valid_age.
        order_by_age(order).first
    if ! guess
      return nil
    end
    guess.place = Guess.joins(:photo).where(place_conditions, self).with_valid_age.count + 1
    guess
  end

  def oldest_unfound_photo
    oldest_unfound_photo = photos.includes(:person).where(game_status: %w(unfound unconfirmed)).order(:dateadded).first
    if oldest_unfound_photo
      oldest_unfound_photo.place = Person.count_by_sql([
        %q{
          select count(*)
          from
            (
              select min(dateadded) min_dateadded
              from photos where game_status in ('unfound', 'unconfirmed')
              group by person_id
            ) oldest_unfounds
          where min_dateadded < ?
        },
        oldest_unfound_photo.dateadded
      ]) + 1
    end
    oldest_unfound_photo
  end

  def most_commented_photo
    most_commented_photo = photos.includes(:person).order('other_user_comments desc').first
    if most_commented_photo
      most_commented_photo.place = Person.count_by_sql([
        %q[
          select count(*)
          from (
            select max(other_user_comments) max_other_user_comments
            from photos
            group by person_id
          ) max_comments
          where max_other_user_comments > ?
        ],
        most_commented_photo.other_user_comments
      ]) + 1
      most_commented_photo
    end
  end

  def most_viewed_photo
    most_something_photo :views
  end

  def most_faved_photo
    most_something_photo :faves
  end

  private def most_something_photo(attribute)
    most_something_photo = photos.includes(:person).order("#{attribute} desc").first
    if most_something_photo
      most_something_photo.place = Person.count_by_sql([
        %Q[
          select count(*)
          from (
            select max(#{attribute}) max_value
            from photos f
            group by person_id
          ) most_something
          where max_value > ?
        ],
        most_something_photo.send(attribute)
      ]) + 1
    end
    most_something_photo
  end

  def guesses_with_associations
    guesses.includes(photo: :person)
  end

  def favorite_posters
    biased_people %Q[
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
    ]
  end

  def photos_with_associations
    photos.includes(guesses: :person).includes(:tags)
  end

  def favoring_guessers
    biased_people %Q[
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
    ]
  end

  def unfound_photos
    photos.where game_status: %w(unfound unconfirmed)
  end

  def revealed_photos
    photos.where(game_status: 'revealed').includes(:tags)
  end

  private def biased_people(sql)
    Person.find_by_sql [sql, id, id]
  end

end
