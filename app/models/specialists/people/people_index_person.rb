class PeopleIndexPerson < Person
  attr_accessor :downcased_username, :guess_count, :post_count, :score_plus_posts, :guesses_per_day, :posts_per_day,
    :posts_per_guess, :guess_speed, :be_guessed_speed, :views_per_post, :faves_per_post

  def self.all_sorted(sorted_by, order)
    people = all
    add_attrs_to_sort_on people
    sorted people, sorted_by, order
  end

  private_class_method def self.add_attrs_to_sort_on(people)
    post_counts = Photo.group(:person_id).count
    guess_counts = Guess.group(:person_id).count
    guesses_per_days = PeopleIndexPerson.guesses_per_day
    posts_per_days = PeopleIndexPerson.posts_per_day
    guess_speeds = PeopleIndexPerson.guess_speeds
    be_guessed_speeds = PeopleIndexPerson.be_guessed_speeds
    views_per_post = PeopleIndexPerson.views_per_post
    faves_per_post = PeopleIndexPerson.faves_per_post

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

  end

  def self.guesses_per_day
    statistic_by_person [%q{
      select person_id id, count(*) / datediff(?, min(commented_at)) statistic
      from guesses group by person_id
    }, Time.now.getutc]
  end

  def self.posts_per_day
    statistic_by_person [%q{
      select person_id id, count(*) / datediff(?, min(dateadded)) statistic
      from photos group by person_id
    }, Time.now.getutc]
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
    find_by_sql(sql).each_with_object({}) { |person, statistic| statistic[person.id] = person[:statistic].to_f }
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
  }.freeze

  private_class_method def self.sorted(people, sorted_by, order)
    if !CRITERIA.key? sorted_by
      raise ArgumentError, "#{sorted_by} is not a valid sort order"
    end
    if !order.in?(['+', '-'])
      raise ArgumentError, "#{order} is not a valid sort direction"
    end

    people.to_a.sort do |x, y|
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
  end

end
