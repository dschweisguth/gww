class AddFlickrUpdateTable < ActiveRecord::Migration
  def self.up
    transaction do
      drop_table :flickr_updates rescue nil
      create_table :flickr_updates, :force => true do |t|
        t.column "updated_at", :datetime, :null => false
      end
    end
  end

  def self.down
    drop_table "syncs"
  end
end
