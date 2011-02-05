class Person < ActiveRecord::Base

  INFINITY = 1.0 / 0

  validates_presence_of :flickrid, :username
  attr_readonly :flickrid

  has_many :photos
  has_many :guesses

  def self.all_sorted(sorted_by, order)
    # I'd have raised Argument error in the case below to avoid duplication,
    # but when I do that something eats the raised error.
    if ! [ 'username', 'score', 'posts', 'guesses-per-day', 'posts-per-guess',
      'time-to-guess', 'time-to-be-guessed', 'comments-to-guess', 
      'comments-to-be-guessed' ].include? sorted_by
      raise ArgumentError, "#{sorted_by} is not a valid sort order"
    end
    if ! ['+', '-'].include? order
      raise ArgumentError, "#{order} is not a valid sort direction"
    end

    post_counts = Photo.count :group => 'person_id'
    guess_counts = Guess.count :group => 'person_id'
    guesses_per_days = Person.guesses_per_day
    guess_speeds = Person.guess_speeds
    be_guessed_speeds = Person.be_guessed_speeds
    comments_to_guess = Person.comments_to_guess
    comments_to_be_guessed = Person.comments_to_be_guessed

    people = all
    people.each do |person|
      person[:downcased_username] = person.username.downcase
      person[:post_count] = post_counts[person.id] || 0
      person[:guess_count] = guess_counts[person.id] || 0
      person[:guesses_per_day] = guesses_per_days[person.id] || 0
      person[:posts_per_guess] =
        person[:post_count].to_f / person[:guess_count]
      person[:guess_speed] = guess_speeds[person.id] || INFINITY
      person[:be_guessed_speed] = be_guessed_speeds[person.id] || INFINITY
      person[:comments_to_guess] = comments_to_guess[person.id] || INFINITY
      person[:comments_to_be_guessed] =
	comments_to_be_guessed[person.id] || INFINITY
    end

    people.sort! do |x, y|
      username = -criterion(x, y, :downcased_username)
      sorted_by_criterion =
	case sorted_by
	when 'username'
	  first_applicable username
	when 'score'
	  first_applicable criterion(x, y, :guess_count),
	    criterion(x, y, :post_count), username
	when 'posts'
	  first_applicable criterion(x, y, :post_count),
	    criterion(x, y, :guess_count), username
	when 'guesses-per-day'
	  first_applicable criterion(x, y, :guesses_per_day),
	    criterion(x, y, :guess_count), username
	when 'posts-per-guess'
	  first_applicable criterion(x, y, :posts_per_guess),
	    criterion(x, y, :post_count), username
	when 'time-to-guess'
	  first_applicable criterion(x, y, :guess_speed),
	    criterion(x, y, :guess_count), username
	when 'time-to-be-guessed'
	  first_applicable criterion(x, y, :be_guessed_speed),
	    criterion(x, y, :post_count), username
	when 'comments-to-guess'
	  first_applicable criterion(x, y, :comments_to_guess),
	    criterion(x, y, :guess_count), username
	when 'comments-to-be-guessed'
	  first_applicable criterion(x, y, :comments_to_be_guessed),
	    criterion(x, y, :post_count), username
        end
      order == '+' ? sorted_by_criterion : -sorted_by_criterion
    end

    people
  end

  def self.criterion(element1, element2, property)
    element2[property] <=> element1[property]
  end
  private_class_method :criterion

  def self.first_applicable(*criteria)
    criteria.find(lambda { 0 }) { |criterion| criterion != 0 }
  end
  private_class_method :first_applicable

  def self.guesses_per_day
    statistic_by_person [
      'select ' +
        'person_id id, ' +
        'count(*) / datediff(?, min(guessed_at)) statistic ' +
      'from guesses group by person_id', Time.now.getutc ]
  end

  def self.guess_speeds
    statistic_by_person \
      'select g.person_id id, avg(unix_timestamp(g.guessed_at) - ' +
	'unix_timestamp(p.dateadded)) statistic ' +
	'from guesses g, photos p ' +
	'where g.photo_id = p.id and ' +
	'unix_timestamp(g.guessed_at) > unix_timestamp(p.dateadded) ' +
	'group by g.person_id'
  end

  def self.be_guessed_speeds
    statistic_by_person \
      'select p.person_id id, avg(unix_timestamp(g.guessed_at) - ' +
	'unix_timestamp(p.dateadded)) statistic ' +
	'from guesses g, photos p ' +
	'where g.photo_id = p.id and ' +
	'unix_timestamp(g.guessed_at) > unix_timestamp(p.dateadded) ' +
	'group by p.person_id'
  end

  def self.comments_to_guess
    statistic_by_person \
      'select id, avg(comment_count) statistic ' +
	'from ' +
	  '(select g.person_id id, count(*) comment_count ' +
	    'from guesses g, people p, comments c ' +
	    'where g.photo_id = c.photo_id and ' +
	      'g.person_id = p.id and ' +
	      'p.flickrid = c.flickrid and ' +
	      'g.guessed_at >= c.commented_at group by g.id) comment_counts ' +
	'group by id'
  end

  def self.comments_to_be_guessed
    statistic_by_person \
      'select id, avg(comment_count) statistic ' +
	'from ' +
	  '(select p.id, count(*) comment_count ' +
	    'from people p, photos ph, guesses g, comments c ' +
	    'where p.id = ph.person_id and ' +
	      'ph.id = g.photo_id and ' +
	      'ph.id = c.photo_id and ' +
	      'p.flickrid != c.flickrid and ' +
	      'g.guessed_at >= c.commented_at ' +
	    'group by g.id) comment_counts ' +
	'group by id'
  end

  def self.statistic_by_person(sql)
    Person.find_by_sql(sql).each_with_object({}) \
      { |person, statistic| statistic[person.id] = person[:statistic].to_f }
  end
  private_class_method :statistic_by_person

  def self.top_guessers(report_time)
    days, weeks, months, years = get_periods(report_time)

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

    years_of_guessing = report_day.getutc.year - Guess.first.guessed_at.year
    years = [ Period.new(report_day.beginning_of_year, report_day + 1.day) ] +
      (1 .. years_of_guessing).map { |i| Period.starting_at(report_day.beginning_of_year - i.years, 1.year) }

    return days, weeks, months, years
  end
  private_class_method :get_periods

  def self.get_scores(begin_date, end_date)
    scores = {}

    guessers = Person.find_by_sql [
      "select p.*, count(*) score from people p, guesses g " +
        "where p.id = g.person_id and ? <= g.guessed_at and g.guessed_at < ? group by p.id", 
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
    scores_by_person = Guess.count :group => :person_id
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

  def self.high_scorers(days)
    people = find_by_sql [
      'select p.*, count(*) score from people p, guesses g ' +
        'where p.id = g.person_id and datediff(?, g.guessed_at) < ? ' +
        'group by p.id having score > 1 order by score desc',
      Time.now.getutc.strftime('%Y-%m-%d'), days
    ]
    high_scorers = []
    current_score = nil
    people.each do |person|
      break if high_scorers.length >= 3 &&
        person[:score] < current_score
      high_scorers.push person
      current_score = person[:score]
    end
    high_scorers
  end

  def self.most_points_in_2010
    find_by_sql [
      'select p.*, count(*) points from people p, guesses g ' +
        'where p.id = g.person_id and ? <= g.guessed_at and g.guessed_at < ? ' +
	'group by p.id order by points desc limit 10',
	Time.utc(2010), Time.utc(2011)
    ]
  end

  def self.most_posts_in_2010
    find_by_sql [
      'select p.*, count(*) posts from people p, photos f ' +
        'where p.id = f.person_id and ? <= f.dateadded and f.dateadded < ? ' +
	'group by p.id order by posts desc limit 10',
	Time.utc(2010), Time.utc(2011)
    ]
  end

  def self.rookies_with_most_points_in_2010
    find_by_sql [
      'select p.*, count(*) points ' +
	'from people p, ' +
	  '(select person_id, min(a.acted) joined ' +
	    'from ' +
	      '(select person_id, guessed_at acted from guesses union all ' +
	        'select person_id, dateadded acted from photos) a ' +
	    'group by person_id having ? <= joined and joined < ?) r, ' +
	  'guesses g ' +
        'where p.id = r.person_id and p.id = g.person_id and g.guessed_at < ?' +
	'group by p.id order by points desc limit 10',
	Time.utc(2010), Time.utc(2011), Time.utc(2011)
    ]
  end

  def self.rookies_with_most_posts_in_2010
    find_by_sql [
      'select p.*, count(*) posts ' +
	'from people p, ' +
	  '(select person_id, min(a.acted) joined ' +
	    'from ' +
	      '(select person_id, guessed_at acted from guesses union all ' +
	        'select person_id, dateadded acted from photos) a ' +
	    'group by person_id having ? <= joined and joined < ?) r, ' + 
	  'photos f ' +
        'where p.id = r.person_id and p.id = f.person_id and f.dateadded < ?' +
	'group by p.id order by posts desc limit 10',
	Time.utc(2010), Time.utc(2011), Time.utc(2011)
    ]
  end

  def self.by_score(people)
    scores = Guess.count :group => :person_id
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

end
