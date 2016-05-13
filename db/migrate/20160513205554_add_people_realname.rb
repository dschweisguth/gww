class AddPeopleRealname < ActiveRecord::Migration
  def change
    add_column :people, :realname, :string
  end
end
