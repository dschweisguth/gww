class DropNudges < ActiveRecord::Migration
  def self.up
    drop_table :nudges
  end

  def self.down
    create_table "nudges", :force => true do |t|
      t.column "kind", :string, :default => "", :null => false
      t.column "ip_address", :string, :default => "", :null => false
      t.column "photo_id", :integer, :default => 0, :null => false
      t.column "person_id", :integer, :default => 0, :null => false
    end
  end

end
