class Photo < ActiveRecord::Base
  include Answer, PhotoAdminPhotosSupport, PhotoAdminRootSupport, PhotoFlickrUpdateSupport, PhotoPeopleSupport,
    PhotoPhotosSupport, PhotoScoreReportsSupport, PhotoStatisticsSupport, PhotoWheresiesSupport, SinglePhotoMapSupport

  belongs_to :person, inverse_of: :photos
  has_many :comments, inverse_of: :photo, dependent: :destroy
  has_many :tags, -> { order :id }, inverse_of: :photo, dependent: :destroy
  has_many :guesses, inverse_of: :photo, dependent: :destroy
  has_one :revelation, inverse_of: :photo, dependent: :destroy
  validates_presence_of :flickrid, :dateadded, :lastupdate, :seen_at,
    :game_status, :views, :faves, :other_user_comments, :member_comments, :member_questions
  attr_readonly :person, :flickrid
  validates_numericality_of :latitude, allow_nil: true
  validates_numericality_of :longitude, allow_nil: true
  validates_numericality_of :accuracy, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0
  validates_inclusion_of :game_status, in: %w(unfound unconfirmed found revealed)
  validates_numericality_of :views, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :faves, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :other_user_comments, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :member_comments, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :member_questions, only_integer: true, greater_than_or_equal_to: 0

  # Not persisted, used in views
  attr_accessor :color, :symbol, :place, :acted_on_at

  after_destroy do
    person.destroy_if_has_no_dependents
  end

  def self.multipoint_without_associations
    joins(:guesses).group("photos.id").having("count(*) > 1")
  end

  def time_elapsed
    time_elapsed_between dateadded, Time.now
  end

  def mapped?
    (accuracy && accuracy >= 12) ? true : false
  end

  def mapped_or_automapped?
    mapped? || ! inferred_latitude.nil?
  end

end
