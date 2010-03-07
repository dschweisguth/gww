class DropGuessesDefaults < ActiveRecord::Migration
  def self.up
    execute "alter table guesses alter column guessed_at drop default"
    execute "alter table guesses alter column photo_id drop default"
    execute "alter table guesses alter column person_id drop default"
    execute "alter table guesses alter column added_at drop default"
  end

  def self.down
    execute "alter table guesses alter column guessed_at set default '0000-00-00 00:00:00'"
    execute "alter table guesses alter column photo_id set default '0'"
    execute "alter table guesses alter column person_id set default '0'"
    execute "alter table guesses alter column added_at set default '0000-00-00 00:00:00'"
  end

end
