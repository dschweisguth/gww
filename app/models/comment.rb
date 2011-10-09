class Comment < ActiveRecord::Base
  belongs_to :photo, :inverse_of => :comments
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at

  def self.add_selected_answer(comment_id, username)
    comment = includes(:photo => [ :person, :revelation ]).find comment_id
    comment.photo.answer comment.username, comment.flickrid, username, comment.comment_text, comment.commented_at
  end

  def self.remove_revelation(comment_id)
    transaction do
      photo = find(comment_id).photo
      photo.revelation.destroy
      photo.update_attribute :game_status, 'unfound'
    end
  end

  def self.remove_guess(comment_id)
    transaction do
      comment = includes(:photo).find comment_id
      guesses = Guess.find_by_sql [
        %q[
          select g.* from guesses g, people p
          where
            g.photo_id = ? and
            g.person_id = p.id and p.flickrid = ? and
            g.comment_text = ?
        ],
        comment.photo_id, comment.flickrid, comment.comment_text
      ]
      if guesses.length != 1
        raise RemoveGuessError,
          "There are #{guesses.length} guesses by the person with the Flickr ID #{comment.flickrid} with the same guess text!?!"
      end
      guesses[0].destroy
      photo = comment.photo
      if ! Guess.where(:photo_id => photo.id).exists?
        photo.update_attribute :game_status, 'unfound'
      end
    end
  end

  class RemoveGuessError < StandardError
  end

  def is_by_poster
    flickrid == photo.person.flickrid
  end

  def is_accepted_answer
    is_by_poster && photo.revelation && photo.revelation.comment_text == comment_text ||
      photo.guesses.any? { |g| g.person.flickrid == flickrid && g.comment_text == comment_text }
  end

end
