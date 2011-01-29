class DropFlickrUpdateMemberCountDefault < ActiveRecord::Migration
  def self.up
    execute "alter table flickr_updates alter column member_count drop default"
  end

  def self.down
    execute "alter table flickr_updates alter column member_count set default '0'"
  end

end
