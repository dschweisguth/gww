class DropDefaultsAgain < ActiveRecord::Migration
  def self.up
    execute "alter table comments alter column photo_id drop default"
    execute "alter table comments alter column flickrid drop default"
    execute "alter table comments alter column username drop default"
    execute "alter table comments alter column commented_at drop default"

    execute "alter table flickr_updates alter column created_at drop default"

    execute "alter table guesses alter column photo_id drop default"
    execute "alter table guesses alter column person_id drop default"
    execute "alter table guesses alter column guessed_at drop default"
    execute "alter table guesses alter column added_at drop default"

    execute "alter table people alter column flickrid drop default"
    execute "alter table people alter column username drop default"

    execute "alter table photos alter column person_id drop default"
    execute "alter table photos alter column flickrid drop default"
    execute "alter table photos alter column farm drop default"
    execute "alter table photos alter column server drop default"
    execute "alter table photos alter column secret drop default"
    execute "alter table photos alter column dateadded drop default"
    execute "alter table photos alter column mapped drop default"
    execute "alter table photos alter column lastupdate drop default"
    execute "alter table photos alter column seen_at drop default"
    execute "alter table photos alter column game_status drop default"

    execute "alter table revelations alter column photo_id drop default"
    execute "alter table revelations alter column revelation_text drop default"
    execute "alter table revelations alter column revealed_at drop default"
    execute "alter table revelations alter column added_at drop default"

  end

  def self.down
    execute "alter table comments alter column photo_id set default '0'"
    execute "alter table comments alter column flickrid set default ''"
    execute "alter table comments alter column username set default ''"
    execute "alter table comments alter column commented_at set default '0000-00-00 00:00:00'"

    execute "alter table flickr_updates alter column created_at set default '0000-00-00 00:00:00'"

    execute "alter table guesses alter column photo_id set default '0'"
    execute "alter table guesses alter column person_id set default '0'"
    execute "alter table guesses alter column guessed_at set default '0000-00-00 00:00:00'"
    execute "alter table guesses alter column added_at set default '0000-00-00 00:00:00'"

    execute "alter table people alter column flickrid set default ''"
    execute "alter table people alter column username set default ''"

    execute "alter table photos alter column person_id set default '0'"
    execute "alter table photos alter column flickrid set default ''"
    execute "alter table photos alter column farm set default ''"
    execute "alter table photos alter column server set default ''"
    execute "alter table photos alter column secret set default ''"
    execute "alter table photos alter column dateadded set default '0000-00-00 00:00:00'"
    execute "alter table photos alter column mapped set default 'false'"
    execute "alter table photos alter column lastupdate set default '0000-00-00 00:00:00'"
    execute "alter table photos alter column seen_at set default '0000-00-00 00:00:00'"
    execute "alter table photos alter column game_status set default 'unfound'"

    execute "alter table revelations alter column photo_id set default '0'"
    execute "alter table revelations alter column revelation_text set default ''"
    execute "alter table revelations alter column revealed_at set default '0000-00-00 00:00:00'"
    execute "alter table revelations alter column added_at set default '0000-00-00 00:00:00'"

  end

end
