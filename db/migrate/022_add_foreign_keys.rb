class AddForeignKeys < ActiveRecord::Migration
  def self.up
    execute "alter table comments add constraint comments_photo_id_fk foreign key (photo_id) references photos (id)"
    execute "alter table guesses add constraint guesses_photo_id_fk foreign key (photo_id) references photos (id)"
    execute "alter table guesses add constraint guesses_person_id_fk foreign key (person_id) references people (id)"
    execute "alter table revelations add constraint revelations_photo_id_fk foreign key (photo_id) references photos (id)"
    execute "alter table revelations add constraint revelations_person_id_fk foreign key (person_id) references people (id)"
  end

  def self.down
    execute "alter table comments drop foreign key comments_photo_id_fk"
    execute "alter table guesses drop foreign key guesses_photo_id_fk"
    execute "alter table guesses drop foreign key guesses_person_id_fk"
    execute "alter table revelations drop foreign key revelations_photo_id_fk"
    execute "alter table revelations drop foreign key revelations_person_id_fk"
  end

end
