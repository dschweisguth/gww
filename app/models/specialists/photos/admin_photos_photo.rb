class AdminPhotosPhoto < Photo
  include PhotosPhotoSupport

  belongs_to :person, inverse_of: :photos, class_name: 'AdminPhotosPerson', foreign_key: 'person_id'
  has_many :comments, inverse_of: :photo, class_name: 'AdminPhotosComment', foreign_key: 'photo_id', dependent: :destroy
  has_many :guesses, inverse_of: :photo, class_name: 'AdminPhotosGuess', foreign_key: 'photo_id', dependent: :destroy
  has_one :revelation, inverse_of: :photo, class_name: 'AdminPhotosRevelation', foreign_key: 'photo_id', dependent: :destroy

  def self.inaccessible
    where("seen_at < ?", FlickrUpdate.maximum(:created_at)).
      where("game_status in ('unfound', 'unconfirmed')").
      order('lastupdate desc').
      includes(:person, :tags)
  end

  def self.multipoint
    multipoint_without_associations.order('lastupdate desc').includes(:person, :tags)
  end

  def self.change_game_status(id, status)
    transaction do
      AdminPhotosGuess.destroy_all_by_photo_id id
      AdminPhotosRevelation.where(photo_id: id).destroy_all
      find(id).update! game_status: status
    end
  end

  def self.add_entered_answer(photo_id, username, answer_text)
    if answer_text.empty?
      raise ArgumentError, 'answer_text may not be empty'
    end

    photo = includes(:person, :revelation).find photo_id
    if username.empty?
      username = photo.person.username
    end
    photo.answer nil, username, answer_text, Time.now.getutc

  end

  def ready_to_score?
    game_status.in?(%w(unfound unconfirmed)) && tags.any? { |tag| tag.raw.downcase.in?(%w(foundinsf revealedinsf)) }
  end

  GAME_STATUS_TAGS = %w(unfoundinsf foundinsf revealedinsf).freeze

  def game_status_tags
    tags.select { |tag| tag.raw.downcase.in?(GAME_STATUS_TAGS) }.sort_by { |tag| GAME_STATUS_TAGS.index tag.raw.downcase }
  end

  def answer(selected_flickrid, entered_username, answer_text, answered_at)
    guesser_flickrid =
      if entered_username.empty?
        selected_flickrid
      else
        AdminPhotosPerson.find_by_username(entered_username)&.flickrid ||
          AdminPhotosComment.find_by_username(entered_username)&.flickrid ||
          raise(AddAnswerError,
            "Sorry; GWW hasn't seen any posts or comments by #{entered_username} yet, " \
              "so doesn't know enough about them to award them a point. " \
              "Did you spell their username correctly?")
      end
    transaction do
      if guesser_flickrid == person.flickrid
        reveal answer_text, answered_at
      else
        guess answer_text, answered_at, guesser_flickrid
      end
    end
  end

  class AddAnswerError < StandardError
  end

  private def reveal(comment_text, commented_at)
    update! game_status: 'revealed'

    revelation_attrs = { comment_text: comment_text, commented_at: commented_at, added_at: Time.now.getutc }
    if revelation
      revelation.update! revelation_attrs
    else
      AdminPhotosRevelation.create!({ photo: self }.merge revelation_attrs)
    end

    guesses.destroy_all

  end

  private def guess(comment_text, commented_at, guesser_flickrid)
    update! game_status: 'found'
    guesser = FlickrUpdateJob::PersonUpdater.create_or_update guesser_flickrid
    guesser = AdminPhotosPerson.find guesser.id
    AdminPhotosGuess.create! photo: self, person: guesser, commented_at: commented_at, comment_text: comment_text, added_at: Time.now.getutc
    revelation&.destroy
  end

end
