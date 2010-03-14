class AddGuessesGuessTextNotNull < ActiveRecord::Migration
  def self.up
    change_column :guesses, :guess_text, :text, :null => false
  end

  def self.down
    change_column :guesses, :guess_text, :text, :null => true
  end

end
