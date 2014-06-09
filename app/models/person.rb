class Person < ActiveRecord::Base
  include PersonWheresiesSupport, PersonScoreReportsSupport

  MIN_GUESSES_FOR_FAVORITE = 10
  MIN_BIAS_FOR_FAVORITE = 2.5

  validates_presence_of :flickrid, :username
  attr_readonly :flickrid

  has_many :photos, inverse_of: :person
  has_many :guesses, inverse_of: :person

  # Not persisted, used in views
  attr_accessor :change_in_standing, :downcased_username, :guess_count, :post_count, :score_plus_posts,
    :guesses_per_day, :posts_per_day, :posts_per_guess, :guess_speed, :be_guessed_speed,
    :views_per_post, :faves_per_post, :poster, :bias, :score, :previous_post_count, :place, :previous_score, :previous_place,
    :label

  # Used in other classes' callbacks
  def destroy_if_has_no_dependents
    if ! Photo.where(person_id: id).exists? && ! Guess.where(person_id: id).exists?
      destroy
    end
  end

  # Used by PeopleController

  def self.find_by_multiple_fields(username)
    find_by_username(username) || find_by_flickrid(username) || (username =~ /\d+/ && find_by_id(username))
  end

  CRITERIA = {
    'username' => %i(downcased_username),
    'score' => %i(guess_count post_count downcased_username),
    'posts' => %i(post_count guess_count downcased_username),
    'score-plus-posts' => %i(score_plus_posts guess_count downcased_username),
    'guesses-per-day' => %i(guesses_per_day guess_count downcased_username),
    'posts-per-day' => %i(posts_per_day post_count downcased_username),
    'posts-per-guess' => %i(posts_per_guess post_count downcased_username),
    'time-to-guess' => %i(guess_speed guess_count downcased_username),
    'time-to-be-guessed' => %i(be_guessed_speed post_count downcased_username),
    'comments-to-guess' => %i(comments_to_guess guess_count downcased_username),
    'comments-per-post' => %i(comments_per_post post_count downcased_username),
    'comments-to-be-guessed' => %i(comments_to_be_guessed post_count downcased_username),
    'views-per-post' => %i(views_per_post post_count downcased_username),
    'faves-per-post' => %i(faves_per_post post_count downcased_username)
  }

  def self.all_sorted(sorted_by, order)
    # I'd have raised ArgumentError in the case below to avoid duplication,
    # but when I do that something eats the raised error.
    if ! CRITERIA.has_key? sorted_by
      raise ArgumentError, "#{sorted_by} is not a valid sort order"
    end
    if ! ['+', '-'].include? order
      raise ArgumentError, "#{order} is not a valid sort direction"
    end

    post_counts = Photo.group(:person_id).count
    guess_counts = Guess.group(:person_id).count
    guesses_per_days = Person.guesses_per_day
    posts_per_days = Person.posts_per_day
    guess_speeds = Person.guess_speeds
    be_guessed_speeds = Person.be_guessed_speeds
    views_per_post = Person.views_per_post
    faves_per_post = Person.faves_per_post

    people = all
    people.each do |person|
      person.downcased_username = person.username.downcase
      person.post_count = post_counts[person.id] || 0
      person.guess_count = guess_counts[person.id] || 0
      person.score_plus_posts = person.post_count + person.guess_count
      person.guesses_per_day = guesses_per_days[person.id] || 0
      person.posts_per_day = posts_per_days[person.id] || 0
      person.posts_per_guess = person.guess_count == 0 ? Float::MAX : person.post_count.to_f / person.guess_count
      person.guess_speed = guess_speeds[person.id] || Float::MAX
      person.be_guessed_speed = be_guessed_speeds[person.id] || Float::MAX
      person.comments_to_guess ||= Float::MAX
      person.comments_to_be_guessed ||= Float::MAX
      person.views_per_post = views_per_post[person.id] || 0.0
      person.faves_per_post = faves_per_post[person.id] || 0.0
    end

    people.to_a.sort! do |x, y|
      total_comparison = 0
      CRITERIA[sorted_by].each do |attr|
        comparison = y.send(attr) <=> x.send(attr)
        if comparison != 0
          total_comparison = comparison
          if attr == :downcased_username
            total_comparison *= -1
          end
          break
        end
      end
      order == '+' ? total_comparison : -total_comparison
    end

    people
  end

  def self.guesses_per_day
    statistic_by_person [ %q{
      select person_id id, count(*) / datediff(?, min(commented_at)) statistic
      from guesses group by person_id
    }, Time.now.getutc ]
  end

  def self.posts_per_day
    statistic_by_person [ %q{
      select person_id id, count(*) / datediff(?, min(dateadded)) statistic
      from photos group by person_id
    }, Time.now.getutc ]
  end

  def self.guess_speeds
    statistic_by_person %q{
      select g.person_id id, avg(unix_timestamp(g.commented_at) - unix_timestamp(p.dateadded)) statistic
      from guesses g, photos p
      where g.photo_id = p.id and unix_timestamp(g.commented_at) > unix_timestamp(p.dateadded)
      group by g.person_id
    }
  end

  def self.be_guessed_speeds
    statistic_by_person %q{
      select p.person_id id, avg(unix_timestamp(g.commented_at) - unix_timestamp(p.dateadded)) statistic
      from guesses g, photos p
      where g.photo_id = p.id and unix_timestamp(g.commented_at) > unix_timestamp(p.dateadded)
      group by p.person_id
    }
  end

  def self.views_per_post
    statistic_by_person 'select person_id id, avg(views) statistic from photos group by person_id'
  end
  
  def self.faves_per_post
    statistic_by_person 'select person_id id, avg(faves) statistic from photos group by person_id'
  end

  private_class_method def self.statistic_by_person(sql)
    find_by_sql(sql).each_with_object({}) { | person, statistic| statistic[person.id] = person[:statistic].to_f }
  end

  def self.nemeses
    nemeses = find_by_sql %Q[
      select guessers.*, f.person_id poster_id,
        count(*) / posters_posts.post_count / guessers_guesses.guess_count *
          (select count(*) from photos) bias
      from guesses g, photos f, people guessers,
        (select person_id, count(*) post_count from photos
          group by person_id having count(*) >= #{MIN_GUESSES_FOR_FAVORITE}) posters_posts,
        (select person_id, count(*) guess_count from guesses
          group by person_id) guessers_guesses
      where g.photo_id = f.id and
        g.person_id = guessers.id and
        f.person_id = posters_posts.person_id and
        g.person_id = guessers_guesses.person_id
      group by guessers.id, poster_id having count(*) >= 10 order by bias desc;
    ]
    poster_ids = nemeses.map { |nemesis| nemesis[:poster_id] }.uniq
    posters = where id: poster_ids
    posters_by_id = posters.each_with_object({}) { |poster, posters_by_id| posters_by_id[poster.id] = poster }
    nemeses.each do |nemesis|
      nemesis.poster = posters_by_id[nemesis[:poster_id]]
      nemesis.bias = nemesis[:bias]
    end
    nemeses
  end

  def self.top_guessers(report_time)
    days, weeks, months, years = get_periods(report_time.getlocal)

    [ days, weeks, months, years ].each do |periods|
      periods.each do |period|
        period.scores = get_scores period.start, period.finish
      end
    end

    return days, weeks, months, years
  end

  private_class_method def self.get_periods(report_time)
    report_day = report_time.beginning_of_day

    days = (0 .. 6).map { |i| Period.starting_at(report_day - i.days, 1.day) }

    weeks = [ Period.new(report_day.beginning_of_week - 1.day, report_day + 1.day) ] +
      (1 .. 5).map { |i| Period.starting_at(report_day.beginning_of_week - i.weeks - 1.day, 1.week) }

    months = [ Period.new(report_day.beginning_of_month, report_day + 1.day) ] +
      (1 .. 12).map { |i| Period.starting_at(report_day.beginning_of_month - i.month, 1.month) }

    years_of_guessing = report_day.getutc.year - Guess.first.commented_at.year
    years = [ Period.new(report_day.beginning_of_year, report_day + 1.day) ] +
      (1 .. years_of_guessing).map { |i| Period.starting_at(report_day.beginning_of_year - i.years, 1.year) }

    return days, weeks, months, years
  end

  private_class_method def self.get_scores(begin_date, end_date)
    scores = {}

    guessers = Person.find_by_sql [
      "select p.*, count(*) score from people p, guesses g " +
        "where p.id = g.person_id and ? <= g.commented_at and g.commented_at < ? group by p.id",
      begin_date.getutc, end_date.getutc ]
    guessers.each do |guesser|
      guesser.score = guesser[:score]
      score = guesser.score
      guessers_with_score = scores[score]
      if guessers_with_score
        guessers_with_score.push guesser
      else
        scores[score] = [ guesser ]
      end
    end

    scores.values.each do |guessers_with_score|
      guessers_with_score.replace(guessers_with_score.sort_by { |guesser| guesser.username.downcase })
    end

    scores
  end

  def self.standing(person)
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

  def self.posts_standing(person)
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

  def favorite_posters
    favorite_posters = Person.find_by_sql [
      %Q[
        select posters.*,
          count(*) / posters_posts.post_count /
            (select count(*) from guesses where person_id = ?) *
            (select count(*) from photos) bias
        from guesses g, photos f, people posters,
          (select person_id, count(*) post_count from photos
            group by person_id having count(*) >= #{MIN_GUESSES_FOR_FAVORITE}) posters_posts
        where g.photo_id = f.id and
          g.person_id = ? and f.person_id = posters.id and
          f.person_id = posters_posts.person_id
        group by posters.id
        having count(*) >= #{MIN_GUESSES_FOR_FAVORITE} and bias >= #{MIN_BIAS_FOR_FAVORITE}
        order by bias desc
      ],
      id, id
    ]
    favorite_posters.each { |fp| fp.bias = fp[:bias] }
    favorite_posters
  end

  def favorite_posters_of
    favorite_posters_of = Person.find_by_sql [
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
        having count(*) >= #{MIN_GUESSES_FOR_FAVORITE} and bias >= #{MIN_BIAS_FOR_FAVORITE}
        order by bias desc
      ],
      id, id
    ]
    favorite_posters_of.each { |fp| fp.bias = fp[:bias] }
    favorite_posters_of
  end

  def paginated_commented_photos(page, per_page = 25)
    Photo
      .where("exists (select 1 from comments c where photos.id = c.photo_id and c.flickrid = ?)", flickrid)
      .includes(:person, { guesses: :person })
      .order('lastupdate desc')
      .paginate(page: page, per_page: per_page)
  end

  # Used in Admin::RootController

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

  private_class_method def self.update_statistic(attribute, sql)
    find_by_sql(sql).each do |person|
      person.update_attribute attribute, person[:statistic]
    end
  end

end
