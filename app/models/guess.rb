class Guess < ActiveRecord::Base
  include Answer, GuessScoreReportsSupport, GuessWheresiesSupport

  belongs_to :photo, inverse_of: :guesses
  belongs_to :person, inverse_of: :guesses
  validates_uniqueness_of :person_id, scope: %w(photo_id comment_text)
  validates_presence_of :comment_text, :commented_at, :added_at

  # Not persisted, used in views
  attr_accessor :place

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

  def self.with_valid_age
    where('unix_timestamp(guesses.commented_at) > unix_timestamp(photos.dateadded)').references :photos
  end

  def self.order_by_age(direction = :asc)
    order("#{GUESS_AGE} #{direction}")
  end

  def self.longest
    with_valid_age.order_by_age(:desc).limit(10).includes(:person, photo: :person)
  end

  def self.shortest
    with_valid_age.order_by_age.limit(10).includes(:person, photo: :person)
  end

  def time_elapsed
    time_elapsed_between photo.dateadded, commented_at
  end

  def ymd_elapsed
    ymd_elapsed_between photo.dateadded, commented_at
  end

end
