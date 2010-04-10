# After restoring some comments in the previous migration, repeat the
# correction of guesses.commented_at done in migration 35. Fixes two guesses.
class FixTimeZonesAgain < ActiveRecord::Migration
  def self.up
    execute "update guesses g set guessed_at = (select commented_at from comments c, people p where c.flickrid = p.flickrid and p.id = g.person_id and c.photo_id = g.photo_id and c.comment_text = g.guess_text limit 1) where exists (select 0 from comments c, people p where c.flickrid = p.flickrid and p.id = g.person_id and c.photo_id = g.photo_id and c.comment_text = g.guess_text)"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end
