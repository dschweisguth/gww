class WheresiesPerson < Person
  has_many :photos, inverse_of: :person, class_name: 'WheresiesPhoto', foreign_key: 'person_id'
  has_many :guesses, inverse_of: :person, class_name: 'WheresiesGuess', foreign_key: 'person_id'

  def self.most_points_in(year)
    most_achievements_in year, :guesses, :commented_at, :points
  end

  def self.most_posts_in(year)
    most_achievements_in year, :photos, :dateadded, :post_count
  end

  private_class_method def self.most_achievements_in(year, achievements, date_column, count_attribute)
    select("people.*, count(*) #{count_attribute}").
      joins(achievements).
      where("? <= #{achievements}.#{date_column}", Time.local(year).getutc).
      where("#{achievements}.#{date_column} < ?", Time.local(year + 1).getutc).
      group(:id).
      order("#{count_attribute} desc").
      limit 10
  end

  def self.rookies_with_most_points_in(year)
    rookies_with_most_achievements_in year, :guesses, :commented_at, :points
  end

  def self.rookies_with_most_posts_in(year)
    rookies_with_most_achievements_in year, :photos, :dateadded, :post_count
  end

  private_class_method def self.rookies_with_most_achievements_in(year, achievements, date_column, count_attribute)
    find_by_sql [
      %Q{
          select people.*, count(*) #{count_attribute}
          from people,
            (select person_id, min(acted.acted) joined
              from
                (select person_id, commented_at acted from guesses union all
                  select person_id, dateadded acted from photos) acted
              group by person_id having :year_start <= joined and joined < :year_end) rookies,
            #{achievements} achievements
          where people.id = rookies.person_id and
            people.id = achievements.person_id and
            achievements.#{date_column} < :year_end
          group by people.id order by #{count_attribute} desc limit 10
        },
      year_start: Time.local(year).getutc, year_end: Time.local(year + 1).getutc
    ]
  end

end
