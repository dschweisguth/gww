class CreateOldUsernames < ActiveRecord::Migration
  def self.up
    create_table :old_usernames do |t|
      t.integer :person_id, null: false
      t.string :old_username, null: false
      t.datetime :created_at, null: false
    end
    execute "alter table old_usernames add constraint old_usernames_person_id_fk foreign key(person_id) references people(id)"
    execute "alter table old_usernames add constraint old_usernames_old_username_unique unique key (old_username)"
    execute "insert into old_usernames select distinct null, p.id person_id, c.username old_username, now() from people p, comments c where p.flickrid = c.flickrid and p.username != c.username order by p.id"
    # The above doesn't address commenters whose usernames changed but who are not players
  end

  def self.down
    drop_table :old_usernames
  end

end
