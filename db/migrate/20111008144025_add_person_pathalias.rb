class AddPersonPathalias < ActiveRecord::Migration
  def self.up
    execute 'alter table people add column pathalias varchar(255) after username'
  end

  def self.down
    remove_column :people, :pathalias
  end

end
