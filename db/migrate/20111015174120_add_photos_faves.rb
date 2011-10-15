class AddPhotosFaves < ActiveRecord::Migration
  def self.up
    execute "alter table photos add column faves int(11) not null default 0 after views"
    execute "alter table photos alter column faves drop default"
  end

  def self.down
    remove_column :photos, :faves
  end

end
