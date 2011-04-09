class AddPhotosInferredLatitudeAndLongitude < ActiveRecord::Migration
  def self.up
    execute 'alter table photos add column inferred_latitude decimal(9, 6)'
    execute 'alter table photos add column inferred_longitude decimal(9, 6)'
  end

  def self.down
    remove_column :photos, :inferred_latitude
    remove_column :photos, :inferred_longitude
  end

end
