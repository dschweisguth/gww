class Comment < ActiveRecord::Base
  belongs_to :photo, :inverse_of => :comments
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at

  def self.remove_revelation(comment_id)
    transaction do
      #noinspection RailsParamDefResolve
      comment = Comment.find comment_id, :include => { :photo => :revelation }
      photo = comment.photo
      photo.revelation.destroy
      photo.game_status = 'unfound'
      photo.save!
    end
  end

  def self.remove_guess(comment_id)
    transaction do
      comment = Comment.find comment_id, :include => :photo
      # TODO Dave combine the following two queries
      guesser = Person.find_by_flickrid comment.flickrid
      guess = Guess.find_by_person_id_and_guess_text guesser.id, comment.comment_text[0, 255]
      guess.destroy
      comment.photo.update_game_status_after_removing_guess
    end
  end

end
