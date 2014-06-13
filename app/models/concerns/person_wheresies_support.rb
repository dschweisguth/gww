module PersonWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def most_points_in(year)
      find_by_sql [ %q{
        select p.*, count(*) points from people p, guesses g
          where p.id = g.person_id and ? <= g.commented_at and g.commented_at < ?
  	      group by p.id order by points desc limit 10
      }, Time.local(year).getutc, Time.local(year + 1).getutc ]
    end

    def most_posts_in(year)
      find_by_sql [ %q{
        select p.*, count(*) post_count from people p, photos f
        where p.id = f.person_id and ? <= f.dateadded and f.dateadded < ?
        group by p.id order by post_count desc limit 10
      }, Time.local(year).getutc, Time.local(year + 1).getutc ]
    end

    def rookies_with_most_points_in(year)
      rookies_with_most_achievements_in year, :guesses, :commented_at, :points
    end

    def rookies_with_most_posts_in(year)
      rookies_with_most_achievements_in year, :photos, :dateadded, :post_count
    end

    def rookies_with_most_achievements_in(year, achievement, date_column, count_attribute)
      find_by_sql [
        %Q{
          select people.*, count(*) #{count_attribute}
          from people,
            (select person_id, min(acted.acted) joined
              from
                (select person_id, commented_at acted from guesses union all
                  select person_id, dateadded acted from photos) acted
              group by person_id having ? <= joined and joined < ?) rookies,
            #{achievement} achievement
          where people.id = rookies.person_id and people.id = achievement.person_id and achievement.#{date_column} < ?
          group by people.id order by #{count_attribute} desc limit 10
        },
        Time.local(year).getutc, Time.local(year + 1).getutc, Time.local(year + 1).getutc
      ]
    end

  end

end
