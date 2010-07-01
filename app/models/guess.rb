class Guess < ActiveRecord::Base

  belongs_to :photo
  belongs_to :person

  def self.count_by_person_per_day
    people = Person.find_by_sql(
      'select ' +
        'person_id id, ' +
        'count(*) / datediff(now(), min(guessed_at)) rate ' +
      'from guesses group by person_id')
    people.each_with_object({}) \
      { |person, rates| rates[person.id] = person[:rate].to_f }
  end

  def self.longest
    all :include => [ :person, { :photo => :person } ],
      :order => "guesses.guessed_at - photos.dateadded desc", :limit => 10
  end

  def self.shortest
    all :include => [ :person, { :photo => :person } ],
      :order => "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600)",
      :limit => 10
  end

  def self.oldest_by(person)
    guess = first :include => [ :person, { :photo => :person } ],
      :conditions => [ "guesses.person_id = ?", person.id ],
      :order => "guesses.guessed_at - photos.dateadded desc"
    guess.years_old >= 1 ? guess : nil
  end

  def self.oldest_place_of(person)
    places = count :include => :photo,
      :conditions => [ "(guesses.guessed_at - photos.dateadded) > (select max(g.guessed_at - p.dateadded) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id )", person.id ]
    places + 1
  end

  def years_old
    ((guessed_at - photo.dateadded).to_i / (365.24 * 24 * 60 * 60)).truncate
  end

end
