class Person < ActiveRecord::Base
  has_many :photos
  has_many :guesses

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

  def self.find_with_score
    find_by_sql(
      'select p.*, count(*) score ' +
      'from people p, guesses g ' +
      'where p.id = g.person_id ' +
      'group by g.person_id ' +
      'order by score desc')
  end

end
