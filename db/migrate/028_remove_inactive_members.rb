class RemoveInactiveMembers < ActiveRecord::Migration
  def self.up
    Person.delete(439)
    Person.delete(402)
  end

  def self.down
    if ! Rails.env.test?
      execute "insert into people (flickrid, username) values ('12037949663@N01', 'caterina')"
      execute "insert into people (flickrid, username) values ('26575274@N00', 'spot20')"
    end
    execute "update people set id = 439 where username = 'caterina'"
    execute "update people set id = 402 where username = 'spot20'"
  end

end
