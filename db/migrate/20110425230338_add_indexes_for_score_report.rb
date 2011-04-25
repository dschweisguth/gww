class AddIndexesForScoreReport < ActiveRecord::Migration
  def self.up
    add_index :photos, :dateadded, :name => :photos_dateadded_index
    add_index :guesses, :commented_at, :name => :guesses_commented_at_index
  end

  def self.down
    remove_index :photos, :name => :photos_dateadded_index
    remove_index :guesses, :name => :guesses_commented_at_index
  end

end
