class AddViewsToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :views, :integer, :null => false
  end

  def self.down
    remove_column :photos, :views
  end

end
