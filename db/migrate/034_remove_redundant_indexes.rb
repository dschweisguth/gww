class RemoveRedundantIndexes < ActiveRecord::Migration
  def self.up
    execute "alter table photos drop index photos_flickrid_index"
    execute "alter table people drop index people_flickrid_index"
  end

  def self.down
    add_index :photos, :flickrid
    add_index :people, :flickrid
  end

end
