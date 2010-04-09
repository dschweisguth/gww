class FixTimeZones < ActiveRecord::Migration
  def self.up

    # Until now all manually set datetime columns were set to times in the
    # local time zone then saved, thereby setting their time zone to UTC
    # without changing the rest of the time. Convert them to the correct time
    # in UTC.
    execute "update comments set commented_at = convert_tz(commented_at, 'America/Los_Angeles', 'UTC')"
    execute "update guesses set added_at = convert_tz(added_at, 'America/Los_Angeles', 'UTC')"
    execute "update revelations set added_at = convert_tz(added_at, 'America/Los_Angeles', 'UTC')"
    execute "update photos set dateadded = convert_tz(dateadded, 'America/Los_Angeles', 'UTC'), lastupdate = convert_tz(lastupdate, 'America/Los_Angeles', 'UTC'), seen_at = convert_tz(seen_at, 'America/Los_Angeles', 'UTC')"

    # Add twice the time zone difference to revealed_at and guessed at to
    # convert them to correct UTC times. Haven't worked out why twice.
    execute "update revelations set revealed_at = revealed_at + interval 2 * (unix_timestamp(convert_tz(revealed_at, 'America/Los_Angeles', 'UTC')) - unix_timestamp(revealed_at)) second"
    execute "update guesses set guessed_at = guessed_at + interval 2 * (unix_timestamp(convert_tz(guessed_at, 'America/Los_Angeles', 'UTC')) - unix_timestamp(guessed_at)) second"

    # For revelations and guesses whose comment is still in the database, just
    # set guessed_at to revealed_at/commented_at.
    execute "update revelations r set revealed_at = (select commented_at from comments c where c.photo_id = r.photo_id and c.comment_text = r.revelation_text limit 1) where exists (select 0 from comments c where c.photo_id = r.photo_id and c.comment_text = r.revelation_text)"
    execute "update guesses g set guessed_at = (select commented_at from comments c, people p where c.flickrid = p.flickrid and p.id = g.person_id and c.photo_id = g.photo_id and c.comment_text = g.guess_text limit 1) where exists (select 0 from comments c, people p where c.flickrid = p.flickrid and p.id = g.person_id and c.photo_id = g.photo_id and c.comment_text = g.guess_text)"
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end

end
