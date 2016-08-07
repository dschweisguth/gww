class Person < ActiveRecord::Base
  include PersonPhotosSupport, PersonStatisticsSupport

  MIN_GUESSES_FOR_FAVORITE = 10
  MIN_BIAS_FOR_FAVORITE = 2.5

  validates :flickrid, :username, presence: true
  attr_readonly :flickrid

  has_many :photos, inverse_of: :person
  has_many :guesses, inverse_of: :person

  attr_accessor :photo_count

  def identifier
    pathalias || flickrid
  end

  # Used in other classes' callbacks
  def destroy_if_has_no_dependents
    if !Photo.where(person_id: id).exists? && !Guess.where(person_id: id).exists?
      destroy
    end
  end

  def self.sort_by_photo_count_and_username(photos_by_actor)
    photos_by_actor.sort do |x, y|
      c = y[1].length <=> x[1].length
      c != 0 ? c : x[0].username.downcase <=> y[0].username.downcase
    end
  end

end
