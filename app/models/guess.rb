class Guess < ActiveRecord::Base
  include Answer

  belongs_to :photo, :inverse_of => :guesses
  belongs_to :person, :inverse_of => :guesses
  #noinspection RailsParamDefResolve
  validates_presence_of :comment_text, :commented_at, :added_at

  def self.destroy_all_by_photo_id(photo_id)
    where(:photo_id => photo_id).destroy_all
  end

  # GWW saves all times as UTC, but the database time zone is Pacific time.
  # unix_timestamp therefore returns the same value for all datetimes in the
  # spring daylight savings jump. This creates spurious zero-second guesses. It
  # also means that unix_timestamp(guesses.commented_at) -
  # unix_timestamp(photos.dateadded) sometimes != guesses.commented_at -
  # photos.dateadded. The current solution is to use unix_timestamp everywhere
  # for consistency. Possibly setting the database timezone to UTC would be a
  # better solution.

  GUESS_AGE =
    'unix_timestamp(guesses.commented_at) - unix_timestamp(photos.dateadded)'
  G_AGE = 'unix_timestamp(g.commented_at) - unix_timestamp(p.dateadded)'
  GUESS_AGE_IS_VALID =
    'unix_timestamp(guesses.commented_at) > unix_timestamp(photos.dateadded)'
  G_AGE_IS_VALID = 'unix_timestamp(g.commented_at) > unix_timestamp(p.dateadded)'

  def self.longest
    #noinspection RailsParamDefResolve
    includes([ :person, { :photo => :person } ]).where(GUESS_AGE_IS_VALID).order("#{GUESS_AGE} desc").limit(10)
  end

  def self.shortest
    #noinspection RailsParamDefResolve
    includes([ :person, { :photo => :person } ]).where(GUESS_AGE_IS_VALID).order(GUESS_AGE).limit(10)
  end

  def self.first_by(guesser)
    includes(:photo).where(:person_id => guesser).order(:commented_at).first
  end

  def self.most_recent_by(guesser)
    includes(:photo).where(:person_id => guesser).order(:commented_at).last
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

  def self.mapped_count(person_id)
    count :joins => :photo,
      :conditions => [ 'guesses.person_id = ? and photos.accuracy >= 12', person_id ]
  end

  def self.all_mapped(person_id)
    all :joins => :photo,
      :conditions => [ 'guesses.person_id = ? and photos.accuracy >= 12', person_id ],
      :order => 'guesses.commented_at',
      :include => :photo
  end

  #noinspection RailsParamDefResolve
  def self.longest_in year
    all :include => [ :person, { :photo => :person } ],
      :conditions =>
	[ "#{GUESS_AGE_IS_VALID} and ? < guesses.commented_at and guesses.commented_at < ?",
	  Time.local(year).getutc, Time.local(year + 1).getutc ],
      :order => "#{GUESS_AGE} desc", :limit => 10
  end

  #noinspection RailsParamDefResolve
  def self.shortest_in year
    all :include => [ :person, { :photo => :person } ],
      :conditions =>
	[ "#{GUESS_AGE_IS_VALID} and ? < guesses.commented_at and guesses.commented_at < ?",
          Time.local(year).getutc, Time.local(year + 1).getutc ],
      :order => GUESS_AGE, :limit => 10
  end

  def self.all_between(from, to)
    all :conditions => [ "? < added_at and added_at <= ?", from.getutc, to.getutc ],
      :include => [ { :photo => :person }, :person ], :order => "commented_at"
  end

  def years_old
    (seconds_old / (365 * 24 * 60 * 60)).truncate
  end

  def seconds_old
    (commented_at - photo.dateadded).to_i
  end

  def time_elapsed
    time_elapsed_between photo.dateadded, commented_at
  end

  def ymd_elapsed
    ymd_elapsed_between photo.dateadded, commented_at
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
