class AddPhotosComments < ActiveRecord::Migration
  def self.up
    execute 'alter table photos add column other_user_comments int(11) not null default 0 after views'
  end

  def self.down
    remove_column :photos, :other_user_comments
  end

end
