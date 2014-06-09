module PersonShowSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def standing(person)
      place = 1
      tied = false
      scores_by_person = Guess.group(:person_id).count
      people_by_score = scores_by_person.keys.group_by { |person_id| scores_by_person[person_id] }
      scores = people_by_score.keys.sort { |a, b| b <=> a }
      scores.each do |score|
        people_with_score = people_by_score[score]
        if people_with_score.include? person.id
          tied = people_with_score.length > 1
          break
        else
          place += people_with_score.length
        end
      end
      return place, tied
    end

    def posts_standing(person)
      place = 1
      tied = false
      posts_by_person = Photo.group(:person_id).count
      people_by_post_count = posts_by_person.keys.group_by { |person_id| posts_by_person[person_id] }
      post_counts = people_by_post_count.keys.sort { |a, b| b <=> a }
      post_counts.each do |post_count|
        people_with_post_count = people_by_post_count[post_count]
        if people_with_post_count.include? person.id
          tied = people_with_post_count.length > 1
          break
        else
          place += people_with_post_count.length
        end
      end
      return place, tied
    end

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

end
