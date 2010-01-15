class RenameAndDeleteGuessTextColumns < ActiveRecord::Migration
  # bring along our own models so we don't have to worry about cached models
  # with obsolete definitions -- from Chad Fowler's "Rails Recipes", 1 ed.
  class Guess < ActiveRecord::Base
    belongs_to :photo
    belongs_to :person
  end

  def self.up
    transaction do
      # delete the original guess text column
      remove_column :guesses, "guess_text"
      # rename the move text column to guess text
      rename_column :guesses, "move_text", "guess_text"
    end
  end

  def self.down
    # rename the guess text column to move text
    rename_column :guesses, "guess_text", "move_text"
    # create a new guess text column in the varchar type
    add_column :guesses, "guess_text", :string, :default => "", :null => false
  end
end
