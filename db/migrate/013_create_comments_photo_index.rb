class CreateCommentsPhotoIndex < ActiveRecord::Migration
  def self.up
    add_index :comments, :photo_id
  end

  def self.down
    remove_index :comments, :photo_id
  end

end
