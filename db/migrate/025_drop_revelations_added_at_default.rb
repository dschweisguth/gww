class DropRevelationsAddedAtDefault < ActiveRecord::Migration
  def self.up
    execute "alter table revelations alter column added_at drop default"
  end

  def self.down
    execute "alter table revelations alter column added_at set default '0000-00-00 00:00:00'"
  end

end
