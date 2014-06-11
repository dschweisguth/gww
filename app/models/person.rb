class Person < ActiveRecord::Base
  include PersonIndexSupport, PersonShowSupport, PersonPeopleSupport, PersonScoreReportsSupport,
    PersonStatisticsSupport, PersonWheresiesSupport

  MIN_GUESSES_FOR_FAVORITE = 10
  MIN_BIAS_FOR_FAVORITE = 2.5

  validates_presence_of :flickrid, :username
  attr_readonly :flickrid

  has_many :photos, inverse_of: :person
  has_many :guesses, inverse_of: :person

  # Not persisted, used in views
  attr_accessor :change_in_standing, :downcased_username, :guess_count, :post_count, :score_plus_posts,
    :guesses_per_day, :posts_per_day, :posts_per_guess, :guess_speed, :be_guessed_speed,
    :views_per_post, :faves_per_post, :poster, :bias, :score, :previous_post_count, :place, :previous_score, :previous_place,
    :label

  def identifier
    pathalias || flickrid
  end

  # Used in other classes' callbacks
  def destroy_if_has_no_dependents
    if ! Photo.where(person_id: id).exists? && ! Guess.where(person_id: id).exists?
      destroy
    end
  end

end
