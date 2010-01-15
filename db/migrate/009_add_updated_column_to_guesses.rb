class AddUpdatedColumnToGuesses < ActiveRecord::Migration
  def self.up
    transaction do
      # create a new guess text column in the varchar type
      add_column :guesses, "added_at", :datetime, :null => false
    end
  end

  def self.down
    # delete the original added at column
    remove_column :guesses, "added_at"
  end
end
