class AddFarmIdColumnToPhotos < ActiveRecord::Migration
  def self.up
    transaction do
      # create a new farm id column in the varchar type
      add_column :photos, "farm", :string, :default => "", :null => false
    end
  end

  def self.down
    # delete the original added at column
    remove_column :photos, "farm"
  end
end
