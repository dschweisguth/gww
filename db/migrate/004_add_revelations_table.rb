class AddRevelationsTable < ActiveRecord::Migration
  def self.up
    transaction do
      drop_table :revelations rescue nil
      create_table :revelations, :force => true do |t|
        t.column "revelation_text", :string, :default => "", :null => false
        t.column "revealed_at", :datetime, :null => false
        t.column "photo_id", :integer, :default => 0, :null => false
        t.column "person_id", :integer, :default => 0, :null => false
      end
    end
  end

  def self.down
    drop_table :revelations
  end
end
