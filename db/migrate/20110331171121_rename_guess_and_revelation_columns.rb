class RenameGuessAndRevelationColumns < ActiveRecord::Migration
  def self.up
    rename_column :guesses, :guessed_at, :commented_at
    rename_column :guesses, :guess_text, :comment_text
    rename_column :revelations, :revealed_at, :commented_at
    rename_column :revelations, :revelation_text, :comment_text
  end

  def self.down
    rename_column :guesses, :commented_at, :guessed_at
    rename_column :guesses, :comment_text, :guess_text
    rename_column :revelations, :commented_at, :revealed_at
    rename_column :revelations, :comment_text, :revelation_text
  end

end
