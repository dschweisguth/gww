class AddLatitudeAndLongitude < ActiveRecord::Migration
  def self.up
    remove_column :photos, :mapped
    execute 'alter table photos add column latitude decimal(9, 6) after secret'
    execute 'alter table photos add column longitude decimal(9, 6) after latitude'
    execute 'alter table photos add column accuracy int(2) after longitude'
  end

  def self.down
    remove_column :photos, :latitude
    remove_column :photos, :longitude
    remove_column :photos, :accuracy
    execute "alter table photos add column mapped enum('false', 'true') not null default 'false' after dateadded"
  end

end
