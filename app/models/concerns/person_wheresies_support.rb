module PersonWheresiesSupport
  extend ActiveSupport::Concern

  module ClassMethods
    def most_points_in(year)
      select("people.*, count(*) points")
        .joins(:guesses)
        .where("? <= guesses.commented_at", Time.local(year).getutc)
        .where("guesses.commented_at < ?", Time.local(year + 1).getutc)
        .group(:id)
        .order("points desc")
        .limit 10
    end

    def most_posts_in(year)
      select("people.*, count(*) post_count")
        .joins(:photos)
        .where("? <= photos.dateadded", Time.local(year).getutc)
        .where("photos.dateadded < ?", Time.local(year + 1).getutc)
        .group(:id)
        .order("post_count desc")
        .limit 10
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
