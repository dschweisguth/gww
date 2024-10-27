class Photo < ActiveRecord::Base
  include Ageable

  belongs_to :person, inverse_of: :photos
  has_many :comments, inverse_of: :photo, dependent: :destroy
  has_many :tags, -> { order :id }, inverse_of: :photo, dependent: :destroy
  has_many :guesses, inverse_of: :photo, dependent: :destroy
  has_one :revelation, inverse_of: :photo, dependent: :destroy

  validates :flickrid, :dateadded, :lastupdate, :seen_at, :game_status, :views, :faves,
    :other_user_comments, :member_comments, :member_questions, presence: true
  validates :latitude, :longitude, numericality: { allow_nil: true }
  validates :accuracy, numericality: { allow_nil: true, only_integer: true, greater_than_or_equal_to: 0 }
  validate do |photo|
    attrs = %i(latitude longitude accuracy)
    are_nil = attrs.map { |attr| photo.send(attr).nil? }
    if !(are_nil.none? || are_nil.all?)
      attrs.each do |attr|
        photo.errors.add attr, "must be nil only if all of #{attrs.to_sentence} are nil, but is #{photo.send(attr) || 'nil'}"
      end
    end
  end
  validates :game_status, inclusion: { in: %w(unfound unconfirmed found revealed) }
  validates :views, :faves, :other_user_comments, :member_comments, :member_questions,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :inferred_latitude, :inferred_longitude, numericality: { allow_nil: true }
  validate do |photo|
    attrs = %i(inferred_latitude inferred_longitude)
    if photo.inferred_latitude.nil? ^ photo.inferred_longitude.nil?
      attrs.each do |attr|
        photo.errors.add attr, "must be nil only if both #{attrs.join ' and '} are nil, but is #{photo.send(attr) || 'nil'}"
      end
    end
  end

  attr_readonly :person, :flickrid

  after_destroy do
    person.destroy_if_has_no_dependents
  end

  def self.find_with_associations(id)
    includes(:person, :revelation, guesses: :person).find id
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
    mapped? || !inferred_latitude.nil?
  end

end
