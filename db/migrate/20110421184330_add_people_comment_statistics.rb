class AddPeopleCommentStatistics < ActiveRecord::Migration
  def self.up
    add_column :people, :comments_to_guess, :decimal, :precision => 7, :scale => 4
    add_column :people, :comments_per_post, :decimal, :precision => 7, :scale => 4, :null => false, :default => 0
    add_column :people, :comments_to_be_guessed, :decimal, :precision => 7, :scale => 4
  end

  def self.down
    remove_column :people, :comments_to_guess
    remove_column :people, :comments_per_post
    remove_column :people, :comments_to_be_guessed
  end

end
