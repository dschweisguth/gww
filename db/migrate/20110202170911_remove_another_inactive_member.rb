class RemoveAnotherInactiveMember < ActiveRecord::Migration
  def self.up
    Person.delete(908)
  end

  def self.down
    if ! Rails.env.test?
      execute "insert into people (flickrid, username) values ('33372884@N00', 'RobertSyrett')"
      execute "update people set id = 908 where username = 'RobertSyrett'"
    end
  end

end
