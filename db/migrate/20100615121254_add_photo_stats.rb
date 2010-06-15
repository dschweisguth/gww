class AddPhotoStats < ActiveRecord::Migration
  def self.up
    add_column :photos, :member_comments, :integer, :null => false,
      :default => 0
    add_column :photos, :member_questions, :integer, :null => false,
      :default => 0
  end

  def self.down
    remove_column :photos, :member_comments
    remove_column :photos, :member_questions
  end

end
