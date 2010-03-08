class RemovePersonFromRevelation < ActiveRecord::Migration
  def self.up
    execute "alter table revelations drop foreign key revelations_person_id_fk"
    remove_column :revelations, :person_id
  end

  def self.down
    add_column :revelations, :person_id, :integer, :null => false
    execute "update revelations r set r.person_id = (select p.person_id from photos p where p.id = r.photo_id)"
    change_column :revelations, :person_id, :integer, :null => false
    execute "alter table revelations add constraint revelations_person_id_fk foreign key (person_id) references people (id)"
  end

end
