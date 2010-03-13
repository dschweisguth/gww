class ReorderColumns < ActiveRecord::Migration
  def self.up
    execute "alter table comments modify photo_id int(11) not null after id, modify flickrid varchar(255) not null after photo_id, modify comment_text text not null after username"
    execute "alter table guesses modify guessed_at datetime not null after guess_text"
    execute "alter table photos modify person_id int(11) not null after id, modify farm varchar(255) not null after flickrid, modify server varchar(255) not null after farm, modify mapped enum('false', 'true') not null after dateadded"
    execute "alter table revelations modify photo_id int(11) not null after id"
  end

  def self.down
  end

end
