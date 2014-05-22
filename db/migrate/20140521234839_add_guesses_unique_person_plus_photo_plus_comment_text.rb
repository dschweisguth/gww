class AddGuessesUniquePersonPlusPhotoPlusCommentText < ActiveRecord::Migration
  def up
    execute "alter table guesses add unique index_guesses_on_photo_id_and_person_id_and_comment_text (photo_id, person_id, comment_text(255))"
  end

  def down
    execute "alter table guesses drop index index_guesses_on_photo_id_and_person_id_and_comment_text"
  end

end
