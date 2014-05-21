class AddTagsMachineTag < ActiveRecord::Migration
  def change
    add_column :tags, :machine_tag, :boolean, null: false, default: false
  end
end
