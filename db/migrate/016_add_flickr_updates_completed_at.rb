class AddFlickrUpdatesCompletedAt < ActiveRecord::Migration
  def self.up
    rename_column :flickr_updates, :updated_at, :created_at
    add_column :flickr_updates, :completed_at, :datetime
  end

  def self.down
    remove_column :flickr_updates, :completed_at
    rename_column :flickr_updates, :created_at, :updated_at
  end

end
