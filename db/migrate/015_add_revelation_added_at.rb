class AddRevelationAddedAt < ActiveRecord::Migration
  def self.up
    add_column :revelations, :added_at, :datetime,
      { :null => false, :default => 0 }
    execute "update revelations set added_at = revealed_at"
    execute "alter table revelations alter added_at drop default"
  end

  def self.down
    remove_column :revelations, :added_at
  end

end
