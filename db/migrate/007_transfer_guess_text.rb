class TransferGuessText < ActiveRecord::Migration
  # bring along our own models so we don't have to worry about cached models
  # with obsolete definitions -- from Chad Fowler's "Rails Recipes", 1 ed.
  class Guess < ActiveRecord::Base
    belongs_to :photo
    belongs_to :person
  end

  def self.up
    transaction do
      # create a new text column to move the current text into
      add_column :guesses, "move_text", :text
      # get the guesses that have text associated with them
      transfer_guesses = Guess.find(:all, :conditions => "guess_text != ''")
      # step through the transfers and move the text to the new column
      transfer_guesses.each do |guess|
        # transfer
        guess[:move_text] = guess[:guess_text]
        # save
        guess.save
      end
    end
  end

  def self.down
    # get the guesses that have text associated with them
    transfer_guesses = Guess.find(:all, :conditions => "move_text != ''")
    # step through the transfers and move the text to the old column
    transfer_guesses.each do |guess|
      # transfer
      guess[:guess_text] = guess[:move_text]
      # save
      guess.save
    end
    # delete the move text column
    remove_column :guesses, "move_text"
  end
end
