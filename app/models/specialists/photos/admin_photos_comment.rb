class AdminPhotosComment < Comment
  belongs_to :photo, inverse_of: :comments, class_name: 'AdminPhotosPhoto', foreign_key: 'photo_id'

  def self.add_selected_answer(comment_id, username)
    comment = find comment_id
    AdminPhotosPhoto.where(id: comment.photo_id).first.answer comment.flickrid, username, comment.comment_text, comment.commented_at
  end

  def self.remove_revelation(comment_id)
    transaction do
      photo = find(comment_id).photo
      photo.revelation.destroy
      photo.update! game_status: 'unfound'
    end
  end

  def self.remove_guess(comment_id)
    transaction do
      comment = find comment_id
      guesses =
        AdminPhotosGuess.joins(:person).
          where("guesses.photo_id = ?", comment.photo_id).
          where("people.flickrid = ?", comment.flickrid).
          where("guesses.comment_text = ?", comment.comment_text).
          readonly false
      guesses.first.destroy # There can be only one Guess for a given photo, person and comment text
      photo = comment.photo
      if photo.guesses.empty?
        photo.update! game_status: 'unfound'
      end
    end
  end

  def by_poster?
    flickrid == photo.person.flickrid
  end

  def accepted_answer?
    by_poster? && photo.revelation&.comment_text == comment_text ||
      photo.guesses.any? { |g| g.person.flickrid == flickrid && g.comment_text == comment_text }
  end

end
