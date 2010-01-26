class AddIndexes < ActiveRecord::Migration
    def self.up
	add_index :photos, :person_id
	add_index :photos, :flickrid
	add_index :guesses, :person_id
	add_index :guesses, :photo_id
        add_index :people, :flickrid
    end

    def self.down
	remove_index :photos, :person_id
	remove_index :photos, :flickrid
	remove_index :guesses, :person_id
	remove_index :guesses, :photo_id
        remove_index :people, :flickrid
    end

end
