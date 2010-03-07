class ConstrainFlickrUpdates < ActiveRecord::Migration
  def self.up
    change_column :flickr_updates, :created_at, :datetime, :null => false
  end

  def self.down
    change_column :flickr_updates, :created_at, :datetime, :null => true
  end

end
