class Comment < ActiveRecord::Base
  belongs_to :photo, inverse_of: :comments
  validates :flickrid, :username, :comment_text, :commented_at, presence: true
  attr_readonly :flickrid, :username, :comment_text, :commented_at
end
