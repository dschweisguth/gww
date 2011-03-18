class Comment < ActiveRecord::Base
  belongs_to :photo, :inverse_of => :comments
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at

  def self.add_selected_answer(comment_id, username)
    #noinspection RailsParamDefResolve
    comment = Comment.find comment_id, :include => { :photo => [ :person, :revelation ] }
    add_answer2(comment.photo, comment.username, comment.flickrid, username,
      comment.comment_text, comment.commented_at)
  end

  def self.add_entered_answer(photo_id, username, comment_text)
    if username.nil? || username.empty?
      raise ArgumentError, 'username may not be nil or empty'
    end
    if comment_text.nil? || comment_text.empty?
      raise ArgumentError, 'comment_text may not be nil or empty'
    end

    #noinspection RailsParamDefResolve
    photo = Photo.find photo_id, :include => [ :person, :revelation ]
    add_answer2(photo, nil, nil, username, comment_text, Time.now.getutc)

  end

  def self.add_answer2(photo, selected_username, selected_flickrid, entered_username, answer_text, answered_at)
    guesser = nil
    if entered_username.empty?
      guesser_username = selected_username
      guesser_flickrid = selected_flickrid
    else
      guesser_username = entered_username
      guesser_flickrid = nil
      if photo.person.username == entered_username
        guesser_flickrid = photo.person.flickrid
      end
      if !guesser_flickrid
        guesser = Person.find_by_username entered_username
        guesser_flickrid = guesser ? guesser.flickrid : nil
      end
      if !guesser_flickrid then
        (guesser_comment = Comment.find_by_username entered_username) &&
          guesser_flickrid = guesser_comment.flickrid
      end
      if !guesser_flickrid
        raise AddAnswerError,
          "Sorry; GWW hasn't seen any posts or comments by #{entered_username} yet, " +
            "so doesn't know enough about them to award them a point. " +
            "Did you spell their username correctly?"
      end
    end

    Photo.transaction do
      if guesser_flickrid == photo.person.flickrid
        photo.game_status = 'revealed'
        photo.save!

        revelation = photo.revelation
        if revelation
          revelation.revelation_text = answer_text
          revelation.revealed_at = answered_at
          revelation.added_at = Time.now.getutc
          revelation.save!
        else
          Revelation.create! \
            :photo => photo,
            :revelation_text => answer_text,
            :revealed_at => answered_at,
            :added_at => Time.now.getutc
        end

        Guess.destroy_all_by_photo_id photo.id

      else
        photo.game_status = 'found'
        photo.save!

        if !guesser then
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
          guess.guessed_at = answered_at
          guess.guess_text = answer_text
          guess.added_at = Time.now.getutc
          guess.save!
        else
          Guess.create! \
            :photo => photo,
            :person => guesser,
            :guess_text => answer_text,
            :guessed_at => answered_at,
            :added_at => Time.now.getutc
        end

        photo.revelation.destroy if photo.revelation

      end
    end
  end
  private_class_method :add_answer2

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
      guesses = Guess.find_by_sql [
        %q[
          select g.* from guesses g, people p
          where
            g.photo_id = ? and
            g.person_id = p.id and p.flickrid = ? and
            g.guess_text = ?
        ],
        comment.photo_id, comment.flickrid, comment.comment_text[0, 255]
      ]
      if guesses.length != 1
        raise RemoveGuessError,
          "There are #{guesses.length} guesses by the person with the Flickr ID #{comment.flickrid} with the same guess text!?!"
      end
      guesses[0].destroy
      photo = comment.photo
      if (Guess.count :conditions => [ "photo_id = ?", photo.id ]) == 0
        photo.game_status = 'unfound'
        photo.save!
      end
    end
  end

  class RemoveGuessError < StandardError
  end

  def is_by_poster
    flickrid == photo.person.flickrid
  end

  def is_accepted_answer
    is_by_poster \
      ? (photo.revelation ? (photo.revelation.revelation_text == comment_text[0, 255]) : false) \
      : (! photo.guesses.detect { |g| g.person.flickrid == flickrid && g.guess_text == comment_text[0, 255] }.nil?)
  end

end
