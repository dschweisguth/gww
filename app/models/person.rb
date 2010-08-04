class Person < ActiveRecord::Base
  has_many :photos
  has_many :guesses

  def self.guesses_per_day
    statistic_by_person \
      'select ' +
        'person_id id, ' +
        'count(*) / datediff(now(), min(guessed_at)) statistic ' +
      'from guesses group by person_id'
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

end
