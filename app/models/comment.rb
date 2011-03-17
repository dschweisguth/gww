class Comment < ActiveRecord::Base
  belongs_to :photo, :inverse_of => :comments
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at

  def self.remove_revelation(comment_id)
    transaction do
      #noinspection RailsParamDefResolve
      comment = Comment.find comment_id, :include => { :photo => :revelation }
      comment.photo.revelation.destroy
      comment.photo.update_game_status_after_removing_revelation
    end
  end

end
