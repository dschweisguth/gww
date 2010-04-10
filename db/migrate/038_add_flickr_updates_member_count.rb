class AddFlickrUpdatesMemberCount < ActiveRecord::Migration
  def self.up
    execute "alter table flickr_updates add column member_count int(11) after created_at"
    execute "update flickr_updates set member_count = 0"
    latest_update_id = RAILS_ENV == 'test' ? 0 : FlickrUpdate.latest.id
    group_info = FlickrCredentials.request 'flickr.groups.getInfo'
    member_count = group_info['group'][0]['members'][0]
    execute "update flickr_updates set member_count = #{member_count} where id = #{latest_update_id}"
    change_column :flickr_updates, :member_count, :integer, :null => false
  end

  def self.down
    remove_column :flickr_updates, :member_count
  end

end
