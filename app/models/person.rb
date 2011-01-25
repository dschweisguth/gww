class Person < ActiveRecord::Base
  validates_presence_of :flickrid, :username

  has_many :photos
  has_many :guesses

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
        'where p.id = f.person_id and ? < f.dateadded and f.dateadded < ? ' +
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
	    'group by person_id having ? < joined and joined < ?) r, ' + 
	  'guesses g ' +
        'where p.id = r.person_id and p.id = g.person_id ' +
	'group by p.id order by points desc limit 10',
	Time.utc(2010), Time.utc(2011)
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
	    'group by person_id having ? < joined and joined < ?) r, ' + 
	  'photos f ' +
        'where p.id = r.person_id and p.id = f.person_id ' +
	'group by p.id order by posts desc limit 10',
	Time.utc(2010), Time.utc(2011)
    ]
  end

end
