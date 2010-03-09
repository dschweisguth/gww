class DropPhotoFlickrStatus < ActiveRecord::Migration
  def self.up
    remove_column :photos, :flickr_status
  end

  def self.down
    execute "alter table photos add column flickr_status enum('in pool','not in pool','missing') not null"
    execute "update photos set flickr_status = 'not in pool' where id in (4021, 4022, 4030)"
    execute "update photos set flickr_status = 'missing' where person_id = 0"
  end

end
