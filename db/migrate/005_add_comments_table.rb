class AddCommentsTable < ActiveRecord::Migration
  def self.up
    transaction do
      drop_table :comments rescue nil
      create_table :comments, :force => true do |t|
        t.column "comment_text", :string, :default => "", :null => false
        t.column "username", :string, :default => "", :null => false
        t.column "userid", :string, :default => "", :null => false
        t.column "commented_at", :datetime, :null => false
        t.column "photo_id", :integer, :default => 0, :null => false
      end
    end
  end

  def self.down
    drop_table :comments
  end
end
