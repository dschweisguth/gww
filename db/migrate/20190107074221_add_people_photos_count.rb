class AddPeoplePhotosCount < ActiveRecord::Migration
  def change
    add_column :people, :photos_count, :integer, default: 0, null: false
  end
end
