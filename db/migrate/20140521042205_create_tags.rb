class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.references :photo, null: false
      t.foreign_key :photos
      t.string :raw, null: false
    end
    add_index :tags, %i(photo_id raw), unique: true
  end
end
