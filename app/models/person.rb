class Person < ActiveRecord::Base

  INFINITY = 1.0 / 0
  MIN_GUESSES_FOR_FAVORITE = 10
  MIN_BIAS_FOR_FAVORITE = 2.5

  validates_presence_of :flickrid, :username
  attr_readonly :flickrid

  has_many :photos, :inverse_of => :person
  has_many :guesses, :inverse_of => :person

  # Used by ScoreReportsController

  def self.all_before(date)
    utc_date = date.getutc
    find_by_sql [
        %q[
          select p.* from people p
          where exists (select 1 from photos where person_id = p.id and dateadded <= ?) or
            exists (select 1 from guesses where person_id = p.id and added_at <= ?)
        ],
        utc_date, utc_date
    ]
  end
  
  def self.high_scorers(now, for_the_past_n_days)
    utc_now = now.getutc
    people = find_by_sql [ %q{
      select p.*, count(*) score from people p, guesses g
      where p.id = g.person_id and ? < g.commented_at and g.added_at <= ?
      group by p.id having score > 1 order by score desc
    }, utc_now - for_the_past_n_days.days, utc_now]
    high_scorers = []
    current_score = nil
    people.each do |person|
      break if high_scorers.length >= 3 && person[:score] < current_score
      high_scorers << person
      current_score = person[:score]
    end
    high_scorers
  end

  def self.top_posters(now, for_the_past_n_days)
    utc_now = now.getutc
    people = find_by_sql [ %q{
      select p.*, count(*) posts from people p, photos f
      where p.id = f.person_id and ? < f.dateadded and f.dateadded <= ?
      group by p.id having posts > 1 order by posts desc
    }, utc_now - for_the_past_n_days.days, utc_now]
    top_posters = []
    current_post_count = nil
    people.each do |person|
      break if top_posters.length >= 3 && person[:posts] < current_post_count
      top_posters << person
      current_post_count = person[:posts]
    end
    top_posters
  end

  def self.by_score(people, to_date)
    #noinspection RailsParamDefResolve
    scores = Guess.where('added_at <= ?', to_date.getutc).group(:person_id).count
    people_by_score = {}
    people.each do |person|
      score = scores[person.id] || 0
      people_with_score = people_by_score[score]
      if ! people_with_score
        people_with_score = []
        people_by_score[score] = people_with_score
      end
      people_with_score << person
    end
    people_by_score
  end

  CLUBS = [ 222, 500, 3300 ]

  # TODO make this work for boundaries above 5000
  MILESTONES = [ 100, 200, 300, 400, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000 ]

  def self.add_change_in_standings(people_by_score, people, previous_report_date, guessers)
    add_score_and_place people_by_score, :score, :place
    people_by_previous_score = Person.by_score people, previous_report_date
    add_score_and_place people_by_previous_score, :previous_score, :previous_place
    Photo.add_posts people, previous_report_date, :previous_posts
    scored_people = Hash[people.map { |person| [person, person] }]
    guessers.each do |guesser_and_guesses|
      guesser = guesser_and_guesses[0]
      scored_guesser = scored_people[guesser]
      score = scored_guesser[:score]
      previous_score = scored_guesser[:previous_score]
      if previous_score == 0 && score > 0
        change = 'scored his or her first point'
        if score > 1
          change << " (and #{score - 1} more)"
        end
        change << (scored_guesser[:previous_posts] == 0 \
          ? '. Congratulations, and welcome to GWSF!' \
          : '. Congratulations!')
      else
        place = scored_guesser[:place]
        previous_place = scored_guesser[:previous_place]
        if place < previous_place
          change = "#{previous_place - place > 1 ? 'jumped' : 'climbed'} from #{previous_place.ordinal} to #{place.ordinal} place"
          passed =
            people.find_all { |person| person[:previous_place] < scored_guesser[:previous_place] } &
              people.find_all { |person| person[:place] > scored_guesser[:place] }
          ties = people_by_score[score] - [ scored_guesser ]
          show_passed = passed.length == 1 || passed.length > 0 && previous_place - place == 2
          if show_passed || ties.length > 0
            change << ','
          end
          if show_passed
            change << " passing #{passed.length == 1 ? passed[0].username : "#{passed.length} other players" }"
          end
          if ties.length > 0 then
            if show_passed
              change << ' and'
            end
            change << ' tying '
            change << (ties.length == 1 ? ties[0].username : "#{ties.length} other players")
          end
        else
          change = ''
        end
        club = CLUBS.find { |club| previous_score < club && club <= score }
        milestone = club ? nil : MILESTONES.find { |milestone| previous_score < milestone && milestone <= score }
        entered_top_ten = previous_place > 10 && place <= 10
        if (club || milestone || entered_top_ten) && ! change.empty?
          change << '.'
        end
        append(change, club) { "Welcome to the #{club} club!" }
        append(change, milestone) { "Congratulations on #{score == milestone ? 'reaching' : 'passing'} #{milestone} points!" }
        append(change, entered_top_ten) { 'Welcome to the top ten!' }
      end
      guesser[:change_in_standing] = change
    end
  end

  def self.add_score_and_place(people_by_score, score_attr_name, place_attr_name)
    place = 1
    people_by_score.keys.sort { |a, b| b <=> a }.each do |score|
      people_with_score = people_by_score[score]
      people_with_score.each do |person|
        person[score_attr_name] = score
        person[place_attr_name] = place
      end
      place += people_with_score.length
    end
  end
  # public only for testing

  def self.append(change, value)
    if value
      if ! change.empty?
        change << ' '
      end
      change << yield
    end
  end
  private_class_method :append

  # Used by PeopleController

  def self.find_by_multiple_fields(username)
    find_by_username(username) || find_by_flickrid(username) || (username =~ /\d+/ && find_by_id(username))
  end

  CRITERIA = {
    'username' => [ :downcased_username ],
    'score' => [ :guess_count, :post_count, :downcased_username ],
    'posts' => [ :post_count, :guess_count, :downcased_username ],
    'score-plus-posts' => [ :score_plus_posts, :guess_count, :downcased_username ],
    'guesses-per-day' => [ :guesses_per_day, :guess_count, :downcased_username ],
    'posts-per-day' => [ :posts_per_day, :post_count, :downcased_username ],
    'posts-per-guess' => [ :posts_per_guess, :post_count, :downcased_username ],
    'time-to-guess' => [ :guess_speed, :guess_count, :downcased_username ],
    'time-to-be-guessed' => [ :be_guessed_speed, :post_count, :downcased_username ],
    'comments-to-guess' => [ :comments_to_guess, :guess_count, :downcased_username ],
    'comments-per-post' => [ :comments_per_post, :post_count, :downcased_username ],
    'comments-to-be-guessed' => [ :comments_to_be_guessed, :post_count, :downcased_username ],
    'views-per-post' => [ :views_per_post, :post_count, :downcased_username ]
  }

  def self.all_sorted(sorted_by, order)
    # I'd have raised Argument error in the case below to avoid duplication,
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

    people = all
    people.each do |person|
      person[:downcased_username] = person.username.downcase
      person[:post_count] = post_counts[person.id] || 0
      person[:guess_count] = guess_counts[person.id] || 0
      person[:score_plus_posts] = person[:post_count] + person[:guess_count] 
      person[:guesses_per_day] = guesses_per_days[person.id] || 0
      person[:posts_per_day] = posts_per_days[person.id] || 0
      person[:posts_per_guess] = person[:post_count].to_f / person[:guess_count]
      person[:guess_speed] = guess_speeds[person.id] || INFINITY
      person[:be_guessed_speed] = be_guessed_speeds[person.id] || INFINITY
      person.comments_to_guess ||= INFINITY
      person.comments_to_be_guessed ||= INFINITY
      person[:views_per_post] = views_per_post[person.id] || 0.0
    end

    people.sort! do |x, y|
      total_comparison = 0
      CRITERIA[sorted_by].each do |attr|
        comparison = y[attr] <=> x[attr]
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
  
  def self.statistic_by_person(sql)
    find_by_sql(sql).each_with_object({}) { | person, statistic| statistic[person.id] = person[:statistic].to_f }
  end
  private_class_method :statistic_by_person

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
    posters = find_all_by_id poster_ids
    posters_by_id = posters.each_with_object({}) { |poster, posters_by_id| posters_by_id[poster.id] = poster }
    nemeses.each { |nemesis| nemesis[:poster] = posters_by_id[nemesis[:poster_id]] }
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

  def self.get_periods(report_time)
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
  private_class_method :get_periods

  def self.get_scores(begin_date, end_date)
    scores = {}

    guessers = Person.find_by_sql [
      "select p.*, count(*) score from people p, guesses g " +
        "where p.id = g.person_id and ? <= g.commented_at and g.commented_at < ? group by p.id",
      begin_date.getutc, end_date.getutc ]
    guessers.each do |guesser|
      score = guesser[:score]
      guessers_with_score = scores[score]
      if guessers_with_score
        guessers_with_score.push guesser
      else
        scores[score] = [ guesser ]
      end
    end

    scores.values.each do |guessers_with_score|
      guessers_with_score.replace \
        guessers_with_score.sort_by { |guesser| guesser.username.downcase }
    end

    scores
  end
  private_class_method :get_scores

  def self.standing(person)
    place = 1
    tied = false
    scores_by_person = Guess.group(:person_id).count
    people_by_score = scores_by_person.keys.group_by \
      { |person_id| scores_by_person[person_id] }
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
    people_by_post_count = posts_by_person.keys.group_by \
      { |person_id| posts_by_person[person_id] }
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
    Person.find_by_sql [
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
  end

  def favorite_posters_of
    Person.find_by_sql [
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
  end

  # Used in WheresiesController

  def self.most_points_in(year)
    find_by_sql [ %q{
      select p.*, count(*) points from people p, guesses g
        where p.id = g.person_id and ? <= g.commented_at and g.commented_at < ?
	group by p.id order by points desc limit 10
    }, Time.local(year).getutc, Time.local(year + 1).getutc ]
  end

  def self.most_posts_in(year)
    find_by_sql [ %q{
      select p.*, count(*) posts from people p, photos f
      where p.id = f.person_id and ? <= f.dateadded and f.dateadded < ?
      group by p.id order by posts desc limit 10
    }, Time.local(year).getutc, Time.local(year + 1).getutc ]
  end

  def self.rookies_with_most_points_in(year)
    find_by_sql [
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
  end

  def self.rookies_with_most_posts_in(year)
    find_by_sql [
      %q{
        select p.*, count(*) posts
        from people p,
          (select person_id, min(a.acted) joined
            from
              (select person_id, commented_at acted from guesses union all
                select person_id, dateadded acted from photos) a
            group by person_id having ? <= joined and joined < ?) r,
          photos f
        where p.id = r.person_id and p.id = f.person_id and f.dateadded < ?
        group by p.id order by posts desc limit 10
      },
      Time.local(year).getutc, Time.local(year + 1).getutc, Time.local(year + 1).getutc
    ]
  end

  # Used in Admin::PhotosController

  def self.update_statistics
    update_all :comments_to_guess => nil, :comments_per_post => 0, :comments_to_be_guessed => nil
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

  def destroy_if_has_no_dependents
    if ! Photo.where(:person_id => id).exists? && ! Guess.where(:person_id => id).exists?
      destroy
    end
  end

end
