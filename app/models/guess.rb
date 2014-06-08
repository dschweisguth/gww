class Guess < ActiveRecord::Base
  include Answer, GuessPeopleSupport, GuessWheresiesSupport

  belongs_to :photo, inverse_of: :guesses
  belongs_to :person, inverse_of: :guesses
  validates_uniqueness_of :person_id, scope: %w(photo_id comment_text)
  validates_presence_of :comment_text, :commented_at, :added_at

  after_destroy do
    person.destroy_if_has_no_dependents
  end

  def self.destroy_all_by_photo_id(photo_id)
    where(photo_id: photo_id).destroy_all
  end

  # GWW saves all times as UTC, but the database time zone is Pacific time.
  # unix_timestamp therefore returns the same value for all datetimes in the
  # spring daylight savings jump. This creates spurious zero-second guesses. It
  # also means that unix_timestamp(guesses.commented_at) -
  # unix_timestamp(photos.dateadded) sometimes != guesses.commented_at -
  # photos.dateadded. The current solution is to use unix_timestamp everywhere
  # for consistency. Possibly setting the database timezone to UTC would be a
  # better solution.

  GUESS_AGE = 'unix_timestamp(guesses.commented_at) - unix_timestamp(photos.dateadded)'
  GUESS_AGE_IS_VALID = 'unix_timestamp(guesses.commented_at) > unix_timestamp(photos.dateadded)'

  def self.longest
    where(GUESS_AGE_IS_VALID).references(:photos).order("#{GUESS_AGE} desc").limit(10).includes(:person, { photo: :person })
  end

  def self.shortest
    where(GUESS_AGE_IS_VALID).references(:photos).order(GUESS_AGE).limit(10).includes(:person, { photo: :person })
  end

  def self.all_between(from, to)
    where("? < added_at and added_at <= ?", from.getutc, to.getutc)
      .order(:commented_at).includes(:person, { photo: :person })
  end

  def years_old
    (seconds_old / (365 * 24 * 60 * 60)).truncate
  end

  def seconds_old
    (self.commented_at - self.photo.dateadded).to_i
  end

  def time_elapsed
    time_elapsed_between self.photo.dateadded, self.commented_at
  end

  def ymd_elapsed
    ymd_elapsed_between self.photo.dateadded, self.commented_at
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

end
