module PhotoAdminPhotosSupport
  extend ActiveSupport::Concern

  module ClassMethods

    def inaccessible
      where("seen_at < ?", FlickrUpdate.maximum(:created_at)).
        where("game_status in ('unfound', 'unconfirmed')").
        order('lastupdate desc').
        includes(:person, :tags)
    end

    def multipoint
      multipoint_without_associations.order('lastupdate desc').includes(:person, :tags)
    end

    def change_game_status(id, status)
      transaction do
        Guess.destroy_all_by_photo_id id
        Revelation.where(photo_id: id).destroy_all
        find(id).update! game_status: status
      end
    end

    def add_entered_answer(photo_id, username, answer_text)
      if answer_text.empty?
        raise ArgumentError, 'answer_text may not be empty'
      end

      photo = Photo.includes(:person, :revelation).find photo_id
      if username.empty?
        username = photo.person.username
      end
      photo.answer nil, username, answer_text, Time.now.getutc

    end

  end

  def ready_to_score?
    %w(unfound unconfirmed).include?(game_status) && tags.any? { |tag| %w(foundinsf revealedinsf).include? tag.raw.downcase }
  end

  GAME_STATUS_TAGS = %w(unfoundinsf foundinsf revealedinsf)

  def game_status_tags
    tags.select { |tag| GAME_STATUS_TAGS.include?(tag.raw.downcase) }.sort_by { |tag| GAME_STATUS_TAGS.index tag.raw.downcase }
  end

  def answer(selected_flickrid, entered_username, answer_text, answered_at)
    guesser_flickrid =
      if entered_username.empty?
        selected_flickrid
      else
        Person.find_by_username(entered_username).try(:flickrid) ||
        Comment.find_by_username(entered_username).try(:flickrid) ||
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
      Revelation.create!({ photo: self }.merge revelation_attrs)
    end

    guesses.destroy_all

  end

  private def guess(comment_text, commented_at, guesser_flickrid)
    update! game_status: 'found'
    guesser = PersonUpdater.create_or_update guesser_flickrid
    Guess.create! photo: self, person: guesser, commented_at: commented_at, comment_text: comment_text, added_at: Time.now.getutc
    revelation.try :destroy
  end

end
