module PhotoStatisticsSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def update_statistics
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

    def infer_geocodes
      logger.info 'Inferring geocodes ...'
      start = Time.now
      answers = Guess.includes(:photo) + Revelation.includes(:photo)
      parser = LocationParser.new Stcline.multiword_street_names
      answer_count = 0
      location_count = 0
      inferred_count = 0
      answers.each do |answer|
        answer_count += 1
        logger.debug "\nInferring geocode for \"#{answer.comment_text}\" ..."
        locations = parser.parse answer.comment_text
        point =
          if locations.any?
            location_count += 1
            shapes = locations.map { |location| Stintersection.geocode location }.compact
            if shapes.length == 1
              inferred_count += 1
              shapes.first
            else
              logger.debug "Found #{shapes.length} geocodes."
              nil
            end
          else
            logger.debug "Found no location."
            nil
          end
        answer.photo.save_geocode point
      end
      finish = Time.now
      logger.info "Examined #{answer_count} photos " +
        "(#{finish - start} s, #{(finish - start) / answer_count} s/photo); " +
        "found #{location_count} candidate locations (#{'%.1f' % (100.0 * location_count / answer_count)}% success); " +
        "inferred #{inferred_count} geocodes (#{'%.1f' % (100.0 * inferred_count / answer_count)}% success)"
    end

  end

  def save_geocode(point)
    lat = point.try :y
    long = point.try :x
    if inferred_latitude != lat || inferred_longitude != long
      update! inferred_latitude: lat, inferred_longitude: long
    end
  end

end
