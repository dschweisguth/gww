class DropUnusedPeopleColumns < ActiveRecord::Migration
  def self.up
    remove_column :people, :photosurl
    remove_column :people, :flickr_status
    remove_column :people, :iconserver
  end

  def self.down
    add_column :people, :photosurl, :string, :default => "", :null => false
    add_column :people, :flickr_status, :string, :default => "", :null => false
    add_column :people, :iconserver, :string, :default => "", :null => false
  end

end
