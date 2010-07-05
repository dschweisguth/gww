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

  def self.speeds
    people = Person.find_by_sql \
      'select g.person_id id, avg(unix_timestamp(g.guessed_at) - ' +
	'unix_timestamp(p.dateadded)) speed ' +
	'from guesses g, photos p ' +
	'where g.photo_id = p.id and ' +
	'unix_timestamp(g.guessed_at) > unix_timestamp(p.dateadded) ' +
	'group by g.person_id'
    people.each_with_object({}) \
      { |person, speeds| speeds[person.id] = person[:speed].to_f }
  end

  def self.longest
    all :include => [ :person, { :photo => :person } ],
      :conditions => "guesses.guessed_at > photos.dateadded",
      :order => "guesses.guessed_at - photos.dateadded desc", :limit => 10
  end

  def self.shortest
    all :include => [ :person, { :photo => :person } ],
      :conditions => "guesses.guessed_at > photos.dateadded",
      :order => "guesses.guessed_at - photos.dateadded", :limit => 10
  end

  # TODO move order SQL into method

  # GWW saves all times as UTC, but the database time zone is Pacific time.
  # unix_timestamp therefore returns the same value for all datetimes in the
  # spring daylight savings jump. This creates spurious zero-second guesses. It
  # also means that unix_timestamp(guesses.guessed_at) -
  # unix_timestamp(photos.dateadded) sometimes != guesses.guessed_at -
  # photos.dateadded. The current solution is to use unix_timestamp everywhere
  # for consistency. Possibly setting the database timezone to UTC would be a
  # better solution.

  def self.oldest(guesser)
    first_guess_with_place guesser, 'guesses.person_id = ?',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded) desc',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded) > ' +
	'(select max(unix_timestamp(g.guessed_at) - unix_timestamp(p.dateadded)) from guesses g, photos p ' +
	  'where g.person_id = ? and g.photo_id = p.id )'
  end

  def self.longest_lasting(poster)
    first_guess_with_place poster, 'photos.person_id = ?',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded) desc',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded) > ' +
	'(select max(unix_timestamp(g.guessed_at) - unix_timestamp(p.dateadded)) from guesses g, photos p ' +
	  'where g.photo_id = p.id and p.person_id = ?)'
  end

  def years_old
    (seconds_old / (365.24 * 24 * 60 * 60)).truncate
  end

  def self.fastest(guesser)
    first_guess_with_place guesser, 'guesses.person_id = ?',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded)',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded) < ' +
	'(select min(unix_timestamp(g.guessed_at) - unix_timestamp(p.dateadded)) ' +
	  'from guesses g, photos p ' +
	  'where g.person_id = ? and g.photo_id = p.id and unix_timestamp(g.guessed_at) > unix_timestamp(p.dateadded))'
  end

  def self.shortest_lasting(poster)
    first_guess_with_place poster, 'photos.person_id = ?',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded)',
      'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded) < ' +
	'(select min(unix_timestamp(g.guessed_at) - unix_timestamp(p.dateadded)) ' +
	  'from guesses g, photos p ' +
	  'where g.photo_id = p.id and p.person_id = ? and unix_timestamp(g.guessed_at) > unix_timestamp(p.dateadded))'
  end

  def self.first_guess_with_place(person, conditions, order, place_conditions)
    guess = first :include => [ :person, { :photo => :person } ],
      :conditions =>
        [ conditions + ' and unix_timestamp(guesses.guessed_at) > ' +
	    'unix_timestamp(photos.dateadded)',
	  person.id ],
      :order => order
    if ! guess
      return nil
    end
    guess[:place] = count(:include => :photo,
      :conditions =>
        [ place_conditions + ' and unix_timestamp(guesses.guessed_at) > ' +
	    'unix_timestamp(photos.dateadded)',
	  person.id ]) + 1
    guess
  end
  private_class_method :first_guess_with_place

  def seconds_old
    (guessed_at - photo.dateadded).to_i
  end

  def time_elapsed
    formatted_age_by_period %w(years months days hours minutes seconds)
  end

  def ymd_elapsed
    result = formatted_age_by_period %w(years months days)
    result.empty? ? time_elapsed : result
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
  private :formatted_age_by_period

  def star_for_age
    age = years_old
    if age >= 3
      :gold
    elsif age >= 2
      :silver
    elsif age >= 1
      :bronze
    else
      nil
    end
  end

  def star_for_speed
    age = seconds_old
    if age <= 10
      :gold
    elsif age <= 60
      :silver
    else
      nil
    end
  end

end
