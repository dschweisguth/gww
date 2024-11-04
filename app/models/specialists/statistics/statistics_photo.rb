class StatisticsPhoto < Photo
  belongs_to :person, inverse_of: :photos, class_name: 'StatisticsPerson', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :photo, dependent: :destroy, class_name: 'StatisticsGuess', foreign_key: 'photo_id'

  def self.update_statistics
    connection.execute %q{
      update photos f set
        other_user_comments =
          ifnull(
            (select count(*)
              from people poster, comments c
              where
                f.person_id = poster.id and
                f.id = c.photo_id and
                poster.flickrid != c.flickrid
              group by c.photo_id),
            0),
        member_comments =
          ifnull(
            (select count(*)
              from people poster, comments c, people commenter, guesses g
              where
                f.person_id = poster.id and
                f.id = c.photo_id and
                poster.flickrid != c.flickrid and
                c.flickrid = commenter.flickrid and
                f.id = g.photo_id and
                c.commented_at <= g.commented_at
              group by c.photo_id),
            0),
        member_questions =
          ifnull(
            (select count(*)
              from people poster, comments c, people commenter, guesses g
              where
                f.person_id = poster.id and
                f.id = c.photo_id and
                poster.flickrid != c.flickrid and
                c.flickrid = commenter.flickrid and
                f.id = g.photo_id and
                c.commented_at <= g.commented_at and
                c.comment_text like '%?%'
              group by c.photo_id),
            0)
    }
  end

  def self.infer_geocodes
    logger.info 'Inferring geocodes ...'
    start = Time.now
    answers = StatisticsGuess.includes(:photo) + StatisticsRevelation.includes(:photo)
    parser = LocationParser.new Stcline.multiword_street_names
    answer_count = answers.length
    located_count, inferred_count = answers.each_with_object([0, 0]) do |answer, counts|
      logger.debug "\nInferring geocode for \"#{answer.comment_text}\" ..."
      locations = parser.parse answer.comment_text
      point, located_one, geocoded_one = unique_geocode locations
      answer.photo.update_geocode! point
      counts[0] += located_one
      counts[1] += geocoded_one
    end
    finish = Time.now
    logger.info "Examined #{answer_count} photos " \
      "(#{finish - start} s, #{(finish - start) / answer_count} s/photo); " \
      "located #{located_count} photos (#{'%.1f' % (100.0 * located_count / answer_count)}% success); " \
      "geocoded #{inferred_count} photos (#{'%.1f' % (100.0 * inferred_count / answer_count)}% success)"
  end

  private_class_method def self.unique_geocode(locations)
    if locations.any?
      shapes = locations.map { |location| Stintersection.geocode location }.compact
      if shapes.length == 1
        [shapes.first, 1, 1]
      else
        logger.debug "Found #{shapes.length} geocodes."
        [nil, 1, 0]
      end
    else
      logger.debug "Found no location."
      [nil, 0, 0]
    end
  end

  def update_geocode!(point)
    lat = point&.y
    long = point&.x
    if inferred_latitude != lat.to_d || inferred_longitude != long.to_d
      update! inferred_latitude: lat, inferred_longitude: long
    end
  end

end
