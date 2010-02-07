class CreatePhotoGameStatusIndex < ActiveRecord::Migration
  def self.up
    add_index :photos, :game_status
  end

  def self.down
    remove_index :photos, :game_status
  end

end
