class DatabaseSetup < ActiveRecord::Migration
  def self.up
    transaction do
      drop_table :photos rescue nil
      create_table :photos, :force => true do |t|
        t.column "flickrid", :string, :default => "", :null => false
        t.column "secret", :string, :default => "", :null => false
        t.column "server", :string, :default => "", :null => false
        t.column "dateadded", :datetime, :null => false
        t.column "lastupdate", :datetime, :null => false
        t.column "seen_at", :datetime, :null => false
        t.column "game_status", :string, :default => "", :null => false
        t.column "flickr_status", :string, :default => "", :null => false
        t.column "mapped", :string, :default => "", :null => false
        t.column "person_id", :integer, :default => 0, :null => false
      end
      
      drop_table :people rescue nil
      create_table :people, :force => true do |t|
        t.column "flickrid", :string, :default => "", :null => false
        t.column "iconserver", :string, :default => "", :null => false
        t.column "username", :string, :default => "", :null => false
        t.column "photosurl", :string, :default => "", :null => false
        t.column "flickr_status", :string, :default => "", :null => false
      end

      drop_table :guesses rescue nil
      create_table :guesses, :force => true do |t|
        t.column "guess_text", :string, :default => "", :null => false
        t.column "guessed_at", :datetime, :null => false
        t.column "photo_id", :integer, :default => 0, :null => false
        t.column "person_id", :integer, :default => 0, :null => false
      end

      drop_table :nudges rescue nil
      create_table :nudges, :force => true do |t|
        t.column "kind", :string, :default => "", :null => false
        t.column "ip_address", :string, :default => "", :null => false
        t.column "photo_id", :integer, :default => 0, :null => false
        t.column "person_id", :integer, :default => 0, :null => false
      end
    end
  end

  def self.down
    drop_table :photos
    drop_table :people
    drop_table :guesses
    drop_table :nudges
  end
end
