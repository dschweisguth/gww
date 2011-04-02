class AddUnknownPerson < ActiveRecord::Migration
  def self.up
    if ! Rails.env.test?
      execute "insert into people (flickrid, username) values('unknown', 'unknown')"
    end
    execute "update people set id = 0 where flickrid = 'unknown'"
    execute "alter table photos add constraint photos_person_id foreign key (person_id) references people (id)"
  end

  def self.down
    execute "alter table photos drop foreign key photos_person_id"
    Person.delete(0)
  end

end
