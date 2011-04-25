class AddAddedAtIndexes < ActiveRecord::Migration
  def self.up
    add_index :guesses, :added_at, :name => :guesses_added_at_index
    add_index :revelations, :added_at, :name => :revelations_added_at_index
  end

  def self.down
    remove_index :guesses, :name => :guesses_added_at_index
    remove_index :revelations, :name => :revelations_added_at_index
  end

end
