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
    if ! guess || guess.years_old < 1
      return nil
    end
    guess[:place] = count(:include => :photo,
      :conditions => [ "(guesses.guessed_at - photos.dateadded) > (select max(g.guessed_at - p.dateadded) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id )", person.id ]) + 1
    guess
  end

  def self.oldest_by_other_of_photo_by(person)
    guess = first :include => [ :person, { :photo => :person } ],
      :conditions => [ "photos.person_id = ?", person.id ],
      :order => "guesses.guessed_at - photos.dateadded desc"
    if ! guess || guess.years_old < 1
      return nil
    end
    guess[:place] = count(:include => :photo,
      :conditions => [ "(guesses.guessed_at - photos.dateadded) > (select max(g.guessed_at - p.dateadded) from guesses g, photos p where g.photo_id = p.id and p.person_id = ?)", person.id ]) + 1
    guess
  end

  def years_old
    (seconds_old / (365.24 * 24 * 60 * 60)).truncate
  end

  def self.fastest_by(person)
    guess = first :include => [ :person, { :photo => :person } ],
      :conditions => [ "guesses.person_id = ?", person.id ],
      :order => "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600)"
    if ! guess || guess.seconds_old > 60
      return nil
    end
    guess[:place] = count(:include => :photo,
      :conditions => [ "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600) < (select min(if(g.guessed_at - p.dateadded > 0, g.guessed_at - p.dateadded, 3600)) from guesses g, photos p where g.person_id = ? and g.photo_id = p.id )", person.id ]) + 1
    guess
  end

  def self.fastest_by_other_of_photo_by(person)
    guess = first :include => [ :person, { :photo => :person } ],
      :conditions => [ "photos.person_id = ?", person.id ],
      :order => "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600)"
    if ! guess || guess.seconds_old > 60
      return nil
    end
    guess[:place] = count(:include => :photo,
      :conditions => [ "if(guesses.guessed_at - photos.dateadded > 0, guesses.guessed_at - photos.dateadded, 3600) < (select min(if(g.guessed_at - p.dateadded > 0, g.guessed_at - p.dateadded, 3600)) from guesses g, photos p where g.photo_id = p.id and p.person_id = ?)", person.id ]) + 1
    guess
  end

  # TODO refactor above methods
  # TODO line up trophy stars
  # TODO put relevant information in each alt+title
  # TODO put alt+title in one partial

  def seconds_old
    (guessed_at - photo.dateadded).to_i
  end

  def time_elapsed
    formatted_age_by_period %w(years months days hours minutes seconds)
  end

  def ymd_elapsed
    formatted_age_by_period %w(years months days)
  end

  def formatted_age_by_period(periods)
    photo_dateadded = photo.dateadded
    years = guessed_at.year - photo_dateadded.year
    months = guessed_at.month - photo_dateadded.month
    days = guessed_at.day - photo_dateadded.day
    hours = guessed_at.hour - photo_dateadded.hour
    minutes = guessed_at.min - photo_dateadded.min
    seconds = guessed_at.sec - photo_dateadded.sec
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
    time_elapsed = periods.each_with_object([]) do |name, list|
        value = eval name
	if value > 0
	  list.push "#{value}&nbsp;#{value == 1 ? name.singularize : name}"
	end
      end
    time_elapsed.join ', '
  end

end
