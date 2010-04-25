class Guess < ActiveRecord::Base

  belongs_to :photo
  belongs_to :person

  def self.count_by_person_per_day
    list = Person.find_by_sql(
      'select ' +
        'person_id id, ' +
        'count(*) / datediff(now(), min(guessed_at)) rate ' +
      'from guesses group by person_id')
    hash = {}
    list.each do |rate|
      hash[rate.id] = rate.rate.to_f
    end
    hash
  end

  def self.longest
    Guess.find :all, :include => [ :photo ],
      :order => "guesses.guessed_at - photos.dateadded desc", :limit => 10
  end

  def self.shortest
    Guess.find :all, :include => [ :photo ],
      :order => "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600)",
      :limit => 10
  end

end
