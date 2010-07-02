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

  def time_elapsed
    begin_date = photo.dateadded
    end_date = guessed_at

    years = end_date.year - begin_date.year
    months = end_date.month - begin_date.month
    days = end_date.day - begin_date.day
    hours = end_date.hour - begin_date.hour
    minutes = end_date.min - begin_date.min
    seconds = end_date.sec - begin_date.sec
    if seconds < 0
      seconds += 60
      minutes -= 1
    end
    if minutes < 0
      minutes += 60
      hours -= 1
    end
    if hours < 0
      hours += 24
      days -= 1
    end
    if days < 0
      days += 30
      months -= 1
    end
    if months < 0
      months += 12
      years -= 1
    end
    time_elapsed = []
    time_elapsed.push "#{years}&nbsp;years" if years > 0
    time_elapsed.push "#{months}&nbsp;months" if months > 0
    time_elapsed.push "#{days}&nbsp;days" if days > 0
    time_elapsed.push "#{hours}&nbsp;hours" if hours > 0
    time_elapsed.push "#{minutes}&nbsp;minutes" if minutes > 0
    time_elapsed.push "#{seconds}&nbsp;seconds" if seconds > 0
    time_elapsed.join ", "
  end

end
