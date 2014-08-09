class AddPhotosDateTaken < ActiveRecord::Migration
  def change
    add_column :photos, :datetaken, :datetime, after: :accuracy
  end
end
