module PersonWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def most_points_in(year)
      guessers = find_by_sql [ %q{
        select p.*, count(*) points from people p, guesses g
          where p.id = g.person_id and ? <= g.commented_at and g.commented_at < ?
  	      group by p.id order by points desc limit 10
      }, Time.local(year).getutc, Time.local(year + 1).getutc ]
      guessers.each { |guesser| guesser.points = guesser[:points] }
      guessers
    end

    def most_posts_in(year)
      posters = find_by_sql [ %q{
        select p.*, count(*) post_count from people p, photos f
        where p.id = f.person_id and ? <= f.dateadded and f.dateadded < ?
        group by p.id order by post_count desc limit 10
      }, Time.local(year).getutc, Time.local(year + 1).getutc ]
      posters.each { |poster| poster.post_count = poster[:post_count] }
      posters
    end

    def rookies_with_most_points_in(year)
      guessers = find_by_sql [
        %q{
          select p.*, count(*) points
          from people p,
            (select person_id, min(a.acted) joined
              from
                (select person_id, commented_at acted from guesses union all
                  select person_id, dateadded acted from photos) a
              group by person_id having ? <= joined and joined < ?) r,
            guesses g
          where p.id = r.person_id and p.id = g.person_id and g.commented_at < ?
          group by p.id order by points desc limit 10
        },
        Time.local(year).getutc, Time.local(year + 1).getutc, Time.local(year + 1).getutc
      ]
      guessers.each { |guesser| guesser.points = guesser[:points] }
      guessers
    end

    def rookies_with_most_posts_in(year)
      rookies = find_by_sql [
        %q{
          select p.*, count(*) post_count
          from people p,
            (select person_id, min(a.acted) joined
              from
                (select person_id, commented_at acted from guesses union all
                  select person_id, dateadded acted from photos) a
              group by person_id having ? <= joined and joined < ?) r,
            photos f
          where p.id = r.person_id and p.id = f.person_id and f.dateadded < ?
          group by p.id order by post_count desc limit 10
        },
        Time.local(year).getutc, Time.local(year + 1).getutc, Time.local(year + 1).getutc
      ]
      rookies.each { |rookie| rookie.post_count = rookie[:post_count] }
      rookies
    end

  end

end
