class DropCommentsDefaults < ActiveRecord::Migration
  def self.up
    execute "alter table comments alter column username drop default"
    execute "alter table comments alter column userid drop default"
    execute "alter table comments alter column commented_at drop default"
    execute "alter table comments alter column photo_id drop default"
  end

  def self.down
    execute "alter table comments alter column username set default ''"
    execute "alter table comments alter column userid set default ''"
    execute "alter table comments alter column commented_at set default '0000-00-00 00:00:00'"
    execute "alter table comments alter column username set default '0'"
  end

end
