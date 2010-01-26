# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 11) do

  create_table "comments", :force => true do |t|
    t.column "username", :string, :default => "", :null => false
    t.column "userid", :string, :default => "", :null => false
    t.column "commented_at", :datetime, :null => false
    t.column "photo_id", :integer, :default => 0, :null => false
    t.column "comment_text", :text
  end

  create_table "flickr_updates", :force => true do |t|
    t.column "updated_at", :datetime, :null => false
  end

  create_table "guesses", :force => true do |t|
    t.column "guessed_at", :datetime, :null => false
    t.column "photo_id", :integer, :default => 0, :null => false
    t.column "person_id", :integer, :default => 0, :null => false
    t.column "guess_text", :text
    t.column "added_at", :datetime, :null => false
  end

  add_index "guesses", ["person_id"], :name => "guesses_person_id_index"
  add_index "guesses", ["photo_id"], :name => "guesses_photo_id_index"

  create_table "nudges", :force => true do |t|
    t.column "kind", :string, :default => "", :null => false
    t.column "ip_address", :string, :default => "", :null => false
    t.column "photo_id", :integer, :default => 0, :null => false
    t.column "person_id", :integer, :default => 0, :null => false
  end

  create_table "people", :force => true do |t|
    t.column "flickrid", :string, :default => "", :null => false
    t.column "iconserver", :string, :default => "", :null => false
    t.column "username", :string, :default => "", :null => false
    t.column "photosurl", :string, :default => "", :null => false
    t.column "flickr_status", :string, :default => "", :null => false
  end

  add_index "people", ["flickrid"], :name => "people_flickrid_index"

  create_table "photos", :force => true do |t|
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
    t.column "farm", :string, :default => "", :null => false
  end

  add_index "photos", ["person_id"], :name => "photos_person_id_index"
  add_index "photos", ["flickrid"], :name => "photos_flickrid_index"

  create_table "revelations", :force => true do |t|
    t.column "revelation_text", :string, :default => "", :null => false
    t.column "revealed_at", :datetime, :null => false
    t.column "photo_id", :integer, :default => 0, :null => false
    t.column "person_id", :integer, :default => 0, :null => false
  end

end
