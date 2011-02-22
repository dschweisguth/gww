class Guess < ActiveRecord::Base
  include Answer

  belongs_to :photo
  belongs_to :person
  #noinspection RailsParamDefResolve
  validates_presence_of :guess_text, :guessed_at, :added_at
  attr_readonly :guess_text, :guessed_at, :added_at

  def self.destroy_all_by_photo_id(photo_id)
    find_all_by_photo_id(photo_id).each do |guess|
      guess.destroy
    end
  end

  # GWW saves all times as UTC, but the database time zone is Pacific time.
  # unix_timestamp therefore returns the same value for all datetimes in the
  # spring daylight savings jump. This creates spurious zero-second guesses. It
  # also means that unix_timestamp(guesses.guessed_at) -
  # unix_timestamp(photos.dateadded) sometimes != guesses.guessed_at -
  # photos.dateadded. The current solution is to use unix_timestamp everywhere
  # for consistency. Possibly setting the database timezone to UTC would be a
  # better solution.

  GUESS_AGE =
    'unix_timestamp(guesses.guessed_at) - unix_timestamp(photos.dateadded)'
  G_AGE = 'unix_timestamp(g.guessed_at) - unix_timestamp(p.dateadded)'
  GUESS_AGE_IS_VALID =
    'unix_timestamp(guesses.guessed_at) > unix_timestamp(photos.dateadded)'
  G_AGE_IS_VALID = 'unix_timestamp(g.guessed_at) > unix_timestamp(p.dateadded)'

  #noinspection RailsParamDefResolve
  def self.longest
    all :include => [ :person, { :photo => :person } ],
      :conditions => GUESS_AGE_IS_VALID,
      :order => "#{GUESS_AGE} desc", :limit => 10
  end

  #noinspection RailsParamDefResolve
  def self.shortest
    all :include => [ :person, { :photo => :person } ],
      :conditions => GUESS_AGE_IS_VALID, :order => GUESS_AGE, :limit => 10
  end

  # TODO Dave test the following two methods

  def self.first_by(guesser)
    first :conditions => [ 'person_id = ?', guesser ], :order => 'guessed_at',
      :include => :photo
  end

  def self.most_recent_by(guesser)
    first :conditions => [ 'person_id = ?', guesser ], :order => 'guessed_at desc',
      :include => :photo
  end

  def self.oldest(guesser)
    first_guess_with_place guesser, 'guesses.person_id = ?', 'desc',
      "#{GUESS_AGE} > (select max(#{G_AGE}) from guesses g, photos p " +
	'where g.person_id = ? and g.photo_id = p.id )'
  end

  def self.longest_lasting(poster)
    first_guess_with_place poster, 'photos.person_id = ?', 'desc',
      "#{GUESS_AGE} > (select max(#{G_AGE}) from guesses g, photos p " +
	'where g.photo_id = p.id and p.person_id = ?)'
  end

  def self.fastest(guesser)
    first_guess_with_place guesser, 'guesses.person_id = ?', 'asc',
      "#{GUESS_AGE} < (select min(#{G_AGE}) from guesses g, photos p " +
	"where g.person_id = ? and g.photo_id = p.id and #{G_AGE_IS_VALID})"
  end

  def self.shortest_lasting(poster)
    first_guess_with_place poster, 'photos.person_id = ?', 'asc',
      "#{GUESS_AGE} < (select min(#{G_AGE}) from guesses g, photos p " +
	"where g.photo_id = p.id and p.person_id = ? and #{G_AGE_IS_VALID})"
  end

  #noinspection RailsParamDefResolve
  def self.first_guess_with_place(person, conditions, order, place_conditions)
    guess = first :include => [ :person, { :photo => :person } ],
      :conditions => [ "#{conditions} and #{GUESS_AGE_IS_VALID}", person.id ],
      :order => "#{GUESS_AGE} #{order}"
    if ! guess
      return nil
    end
    guess[:place] = count(:include => :photo,
      :conditions =>
        [ "#{place_conditions} and #{GUESS_AGE_IS_VALID}", person.id ]) + 1
    guess
  end
  private_class_method :first_guess_with_place

  #noinspection RailsParamDefResolve
  def self.shortest_in_2010
    all :include => [ :person, { :photo => :person } ],
      :conditions =>
	[ "#{GUESS_AGE_IS_VALID} and ? < guesses.guessed_at and guesses.guessed_at < ?",
	  Time.utc(2010), Time.utc(2011) ],
      :order => GUESS_AGE, :limit => 10
  end

  def self.all_since(update)
    all :conditions => [ "added_at > ?", update.created_at ],
      :include => [ { :photo => :person }, :person ], :order => "guessed_at"
  end

  def years_old
    (seconds_old / (365 * 24 * 60 * 60)).truncate
  end

  def seconds_old
    (guessed_at - photo.dateadded).to_i
  end

  def time_elapsed
    time_elapsed_between photo.dateadded, guessed_at
  end

  def ymd_elapsed
    ymd_elapsed_between photo.dateadded, guessed_at
  end

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

  def destroy
    super
    person.destroy_if_has_no_dependents
  end

end
