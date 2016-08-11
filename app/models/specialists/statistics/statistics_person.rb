class StatisticsPerson < Person
  def self.update_statistics
    update_all comments_to_guess: nil, comments_per_post: 0, comments_to_be_guessed: nil
    update_statistic :comments_to_guess, %q{
      select id, avg(comment_count) statistic
      from (
        select p.id, count(*) comment_count
        from guesses g, people p, comments c
        where g.photo_id = c.photo_id and
          g.person_id = p.id and
          p.flickrid = c.flickrid and
          g.commented_at >= c.commented_at group by g.id
      ) comment_counts
      group by id
    }
    update_statistic :comments_per_post, %q{
      select person_id id, avg(comment_count) statistic
      from (
        select f.person_id, count(*) comment_count
        from photos f, people p, comments c
        where f.id = c.photo_id and
          f.person_id = p.id and
          p.flickrid != c.flickrid
        group by f.id
      ) comment_counts
      group by id
    }
    update_statistic :comments_to_be_guessed, %q{
      select id, avg(comment_count) statistic
      from (
        select p.id, count(*) comment_count
        from people p, photos ph, guesses g, comments c
        where p.id = ph.person_id and
          ph.id = g.photo_id and
          ph.id = c.photo_id and
          p.flickrid != c.flickrid and
          g.commented_at >= c.commented_at
        group by g.id
      ) comment_counts
      group by id
    }
  end

  def self.update_statistic(attribute, sql)
    find_by_sql(sql).each do |person|
      person.update_attribute attribute, person[:statistic]
    end
  end
  private_class_method :update_statistic

end
