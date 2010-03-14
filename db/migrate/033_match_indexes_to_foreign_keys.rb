class MatchIndexesToForeignKeys < ActiveRecord::Migration
  def self.up
    execute "alter table comments drop foreign key comments_photo_id_fk"
    remove_index :comments, :photo_id
    execute "alter table comments add constraint comments_photo_id_fk foreign key (photo_id) references photos (id)"

    execute "alter table guesses drop foreign key guesses_photo_id_fk"
    remove_index :guesses, :photo_id
    execute "alter table guesses add constraint guesses_photo_id_fk foreign key (photo_id) references photos (id)"

    execute "alter table guesses drop foreign key guesses_person_id_fk"
    remove_index :guesses, :person_id
    execute "alter table guesses add constraint guesses_person_id_fk foreign key (person_id) references people (id)"

    execute "alter table photos drop foreign key photos_person_id"
    remove_index :photos, :person_id
    execute "alter table photos add constraint photos_person_id_fk foreign key (person_id) references people (id)"

  end

  def self.down
    execute "alter table comments drop foreign key comments_photo_id_fk"
    add_index :comments, :photo_id
    execute "alter table comments add constraint comments_photo_id_fk foreign key (photo_id) references photos (id)"

    execute "alter table guesses drop foreign key guesses_photo_id_fk"
    add_index :guesses, :photo_id
    execute "alter table guesses add constraint guesses_photo_id_fk foreign key (photo_id) references photos (id)"

    execute "alter table guesses drop foreign key guesses_person_id_fk"
    add_index :guesses, :person_id
    execute "alter table guesses add constraint guesses_person_id_fk foreign key (person_id) references people (id)"

    execute "alter table photos drop foreign key photos_person_id_fk"
    add_index :photos, :person_id
    execute "alter table photos add constraint photos_person_id foreign key (person_id) references people (id)"

  end

end
