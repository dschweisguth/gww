class AddPeopleIspro < ActiveRecord::Migration
  def change
    add_column :people, :ispro, :boolean, default: false, null: false
  end
end
