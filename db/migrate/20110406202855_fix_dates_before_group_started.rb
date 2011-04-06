class FixDatesBeforeGroupStarted < ActiveRecord::Migration
  def self.up
    execute "update photos set dateadded = '2005-05-20 01:02:38' where id = 4030"
    execute "update guesses set added_at = '2005-05-19 17:27:13' where photo_id = 4030"
  end

  def self.down
    execute "update photos set dateadded = '2005-03-20 01:02:38' where id = 4030"
    execute "update guesses set added_at = '2005-03-19 17:27:13' where photo_id = 4030"
  end

end
