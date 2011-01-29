class Comment < ActiveRecord::Base
  belongs_to :photo
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at
end
