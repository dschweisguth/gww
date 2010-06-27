class Guess < ActiveRecord::Base

  belongs_to :photo
  belongs_to :person

  def self.count_by_person_per_day
    people = Person.find_by_sql(
      'select ' +
        'person_id id, ' +
        'count(*) / datediff(now(), min(guessed_at)) rate ' +
      'from guesses group by person_id')
    people.inject({}) \
      { |rates, person| rates[person.id] = person[:rate].to_f; rates }
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

end
