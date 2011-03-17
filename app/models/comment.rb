class Comment < ActiveRecord::Base
  belongs_to :photo, :inverse_of => :comments
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at

  def self.add_answer(comment_id, username)
    #noinspection RailsParamDefResolve
    comment = Comment.find comment_id, :include => { :photo => [ :person, :revelation ] }

    guesser = nil
    if username.empty?
      guesser_username = comment.username
      guesser_flickrid = comment.flickrid
    else
      # Note that this branch results in a guess that can't be individually removed
      guesser_username = username
      guesser_flickrid = nil
      if comment.photo.person.username == username
        guesser_flickrid = comment.photo.person.flickrid
      end
      if ! guesser_flickrid
        guesser = Person.find_by_username username
        guesser_flickrid = guesser ? guesser.flickrid : nil
      end
      if ! guesser_flickrid then
        (guesser_comment = Comment.find_by_username username) &&
          guesser_flickrid = guesser_comment.flickrid
      end
      if ! guesser_flickrid
        raise AddAnswerError,
          "Sorry; GWW hasn't seen any posts or comments by #{username} yet, " +
            "so doesn't know enough about them to award them a point. " +
            "Did you spell their username correctly?"
      end
    end

    Photo.transaction do
      photo = comment.photo
      if guesser_flickrid == photo.person.flickrid
        photo.game_status = 'revealed'
        photo.save!

        revelation = photo.revelation
        if revelation
          revelation.revelation_text = comment.comment_text
          revelation.revealed_at = comment.commented_at
          # TODO Dave update added_at
          revelation.save!
        else
          Revelation.create! \
            :photo => photo,
            :revelation_text => comment.comment_text,
            :revealed_at => comment.commented_at,
            :added_at => Time.now.getutc
        end

        Guess.destroy_all_by_photo_id photo.id

      else
        photo.game_status = 'found'
        photo.save!

        if ! guesser then
          guesser = Person.find_by_flickrid guesser_flickrid
        end
        if guesser
          guess = Guess.find_by_photo_id_and_person_id photo.id, guesser.id
        else
          guesser = Person.create! \
            :flickrid => guesser_flickrid,
            :username => guesser_username
          guess = nil
        end
        if guess
          guess.guessed_at = comment.commented_at
          guess.guess_text = comment.comment_text
          # TODO Dave update added_at
          guess.save!
        else
          Guess.create! \
            :photo => photo,
            :person => guesser,
            :guess_text => comment.comment_text,
            :guessed_at => comment.commented_at,
            :added_at => Time.now.getutc
        end

        photo.revelation.destroy if photo.revelation

      end
    end

  end

  class AddAnswerError < StandardError
  end 

  def self.remove_revelation(comment_id)
    transaction do
      #noinspection RailsParamDefResolve
      comment = Comment.find comment_id, :include => { :photo => :revelation }
      photo = comment.photo
      photo.revelation.destroy
      photo.game_status = 'unfound'
      photo.save!
    end
  end

  def self.remove_guess(comment_id)
    transaction do
      comment = Comment.find comment_id, :include => :photo
      # TODO Dave combine the following two queries
      guesser = Person.find_by_flickrid comment.flickrid
      guess = Guess.find_by_person_id_and_guess_text guesser.id, comment.comment_text[0, 255]
      guess.destroy
      photo = comment.photo
      if (Guess.count :conditions => [ "photo_id = ?", photo.id ]) == 0
        photo.game_status = 'unfound'
        photo.save!
      end
    end
  end

end
