class RetypeRevelationCommentText < ActiveRecord::Migration
  def self.up
    change_column :revelations, :comment_text, :text, :null => false
    execute %q{
      update revelations r
        set comment_text = (
          select c.comment_text from photos f, people p, comments c
          where r.photo_id = f.id and f.person_id = p.id and
            p.flickrid = c.flickrid and
            f.id = c.photo_id and
            substring(c.comment_text, 1, 255) = r.comment_text
        )
        where exists (
          select 1 from photos f, people p, comments c
          where r.photo_id = f.id and
            f.person_id = p.id and
            p.flickrid = c.flickrid and
            f.id = c.photo_id and
            c.comment_text != r.comment_text and
            substring(c.comment_text, 1, 255) = r.comment_text
        )
    }
  end

  def self.down
    change_column :revelations, :comment_text, :string, :null => false
  end

end
