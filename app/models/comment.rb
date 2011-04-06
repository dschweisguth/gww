class Comment < ActiveRecord::Base
  belongs_to :photo, :inverse_of => :comments
  validates_presence_of :flickrid, :username, :comment_text, :commented_at
  attr_readonly :flickrid, :username, :comment_text, :commented_at

  def self.add_selected_answer(comment_id, username)
    comment = includes(:photo => [ :person, :revelation ]).find comment_id
    add_answer comment.photo, comment.username, comment.flickrid, username,
      comment.comment_text, comment.commented_at
  end

  def self.add_entered_answer(photo_id, username, answer_text)
    if answer_text.empty?
      raise ArgumentError, 'answer_text may not be empty'
    end

    photo = Photo.includes(:person, :revelation).find photo_id
    if username.empty?
      username = photo.person.username
    end
    add_answer photo, nil, nil, username, answer_text, Time.now.getutc

  end

  def self.add_answer(photo, selected_username, selected_flickrid, entered_username, answer_text, answered_at)
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
      if !guesser_flickrid
        guesser_comment = Comment.find_by_username entered_username
        if guesser_comment
          guesser_flickrid = guesser_comment.flickrid
        end
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
          revelation.comment_text = answer_text
          revelation.commented_at = answered_at
          revelation.added_at = Time.now.getutc
          revelation.save!
        else
          Revelation.create! \
            :photo => photo,
            :comment_text => answer_text,
            :commented_at => answered_at,
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
          guess.commented_at = answered_at
          guess.comment_text = answer_text
          guess.added_at = Time.now.getutc
          guess.save!
        else
          Guess.create! \
            :photo => photo,
            :person => guesser,
            :comment_text => answer_text,
            :commented_at => answered_at,
            :added_at => Time.now.getutc
        end

        photo.revelation.destroy if photo.revelation

      end
    end
  end
  private_class_method :add_answer

  class AddAnswerError < StandardError
  end 

  def self.remove_revelation(comment_id)
    transaction do
      comment = includes(:photo => :revelation).find comment_id
      photo = comment.photo
      photo.revelation.destroy
      photo.game_status = 'unfound'
      photo.save!
    end
  end

  def self.remove_guess(comment_id)
    transaction do
      comment = includes(:photo).find comment_id
      guesses = Guess.find_by_sql [
        %q[
          select g.* from guesses g, people p
          where
            g.photo_id = ? and
            g.person_id = p.id and p.flickrid = ? and
            g.comment_text = ?
        ],
        comment.photo_id, comment.flickrid, comment.comment_text
      ]
      if guesses.length != 1
        raise RemoveGuessError,
          "There are #{guesses.length} guesses by the person with the Flickr ID #{comment.flickrid} with the same guess text!?!"
      end
      guesses[0].destroy
      photo = comment.photo
      if ! Guess.where(:photo_id => photo.id).exists?
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
      ? (photo.revelation ? (photo.revelation.comment_text == comment_text) : false) \
      : (! photo.guesses.detect { |g| g.person.flickrid == flickrid && g.comment_text == comment_text }.nil?)
  end

end
