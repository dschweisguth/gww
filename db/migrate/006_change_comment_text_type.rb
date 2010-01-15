class ChangeCommentTextType < ActiveRecord::Migration
  def self.up
    transaction do
      remove_column :comments, "comment_text"
      add_column :comments, "comment_text", :text
    end
  end

  def self.down
    remove_column :comments, "comment_text"
    add_column :comments, "comment_text", :string, :default => "", :null => false
  end
end
