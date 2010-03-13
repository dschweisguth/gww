class AddNotNullConstraintsToComments < ActiveRecord::Migration
  def self.up
    execute "alter table comments modify column flickrid varchar(255) not null"
    execute "alter table comments modify column comment_text text not null"
  end

  def self.down
    execute "alter table comments modify column flickrid varchar(255)"
    execute "alter table comments modify column comment_text text"
  end

end
