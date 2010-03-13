class RenameCommentsUserId < ActiveRecord::Migration
  def self.up
    rename_column :comments, :userid, :flickrid
  end

  def self.down
    rename_column :comments, :flickrid, :userid
  end

end
