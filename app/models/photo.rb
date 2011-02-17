class Photo < ActiveRecord::Base
  belongs_to :person
  has_many :guesses
  has_many :comments
  has_one :revelation
  validates_presence_of :flickrid, :dateadded, :mapped, :lastupdate, :seen_at,
    :game_status, :views, :member_comments, :member_questions
  attr_readonly :person, :flickrid
  validates_inclusion_of :mapped, :in => %w(false true)
  validates_inclusion_of :game_status, :in => %w(unfound unconfirmed found revealed)
  validates_numericality_of :views, :only_integer => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :member_comments, :only_integer => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :member_questions, :only_integer => true,
    :greater_than_or_equal_to => 0

  # Used by PhotosController

  def self.all_sorted_and_paginated(sorted_by, order, page, per_page)
    paginate_by_sql(
      'select p.* ' +
        'from photos p, people poster ' +
        'where p.person_id = poster.id ' +
        'order by ' + order_by(sorted_by, order),
      :page => page, :per_page => per_page)
  end

  SORTED_BY = {
    'username' => { :secondary => [ 'date-added' ],
      :column => 'lower(poster.username)', :default_order => '+' },
    'date-added' => { :secondary => [ 'username' ],
      :column => 'dateadded', :default_order => '-' },
    'last-updated' => { :secondary => [ 'username' ],
      :column => 'lastupdate', :default_order => '-' },
    'views' => { :secondary => [ 'username' ],
      :column => 'views', :default_order => '-' },
    'member-comments' => { :secondary => [ 'date-added', 'username' ],
      :column => 'member_comments', :default_order => '-' },
    'member-questions' => { :secondary => [ 'date-added', 'username' ],
      :column => 'member_questions', :default_order => '-' }
  }

  def self.order_by(sorted_by, order)
    term_names = [ sorted_by, *SORTED_BY[sorted_by][:secondary] ]
    terms = term_names.map do |term_name|
      term = SORTED_BY[term_name][:column]
      if SORTED_BY[term_name][:default_order] != order
	term += ' desc'
      end
      term
    end
    terms.join ', '
  end
  private_class_method :order_by

  def self.unfound_or_unconfirmed
    all :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc"
  end

  # Used by WheresiesController

  def self.most_viewed_in_2010
    find :all,
      :conditions =>
	[ '? <= dateadded and dateadded < ?', Time.utc(2010), Time.utc(2011) ],
      :order => 'views desc',
      :limit => 10,
      :include => :person
  end

  def self.most_commented_in_2010
    find_by_sql [
      'select f.*, count(*) comments from photos f, comments c ' +
        'where ? <= f.dateadded and f.dateadded < ? and f.id = c.photo_id ' +
	'group by f.id order by comments desc limit 10',
      Time.utc(2010), Time.utc(2011) ]
  end

  # Used by Admin::RootController, Admin::GuessesController

  def self.unfound_or_unconfirmed_count
    count :conditions => "game_status in ('unfound', 'unconfirmed')"
  end

  # Used by Admin::PhotosController

  def self.update_all_from_flickr
    group_info = FlickrCredentials.request 'flickr.groups.getInfo'
    member_count = group_info['group'][0]['members'][0]
    update = FlickrUpdate.create! :member_count => member_count

    page = 1
    parsed_photos = nil
    existing_people = {}
    new_photo_count = 0
    new_person_count = 0
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      logger.info "Getting page #{page} ..."
      photos_xml = FlickrCredentials.request 'flickr.groups.pools.getPhotos',
        'per_page' => '500', 'page' => page.to_s,
        'extras' => 'geo,last_update,views'
      parsed_photos = photos_xml['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }

      logger.info "Updating database from page #{page} ..."
      transaction do
        now = Time.now.getutc
        update_seen_at photo_flickrids, now

        people_flickrids =
          Set.new parsed_photos['photo'].map { |p| p['owner'] }
        existing_people_flickrids = people_flickrids - existing_people.keys
        Person.find_all_by_flickrid(existing_people_flickrids.to_a).each do |person|
          existing_people[person.flickrid] = person
        end

        existing_photos = find_all_by_flickrid(photo_flickrids).index_by &:flickrid

        parsed_photos['photo'].each do |parsed_photo|
          person_flickrid = parsed_photo['owner']
          person = existing_people[person_flickrid]
          if ! person
            person = Person.new :flickrid => person_flickrid
            existing_people[person_flickrid] = person
            new_person_count += 1
          end
          old_person_username = person.username
          person.username = parsed_photo['ownername']
          if person.id.nil? || person.username != old_person_username
            person.save!
          end

          photo_flickrid = parsed_photo['id']
          photo = existing_photos[photo_flickrid]
          if ! photo
            photo = Photo.new \
              :flickrid => photo_flickrid,
              :game_status => 'unfound',
              :seen_at => now
            new_photo_count += 1
          end
          old_photo_farm = photo.farm
          photo.farm = parsed_photo['farm']
          old_photo_server = photo.server
          photo.server = parsed_photo['server']
          old_photo_secret = photo.secret
          photo.secret = parsed_photo['secret']
          old_photo_mapped = photo.mapped
          photo.mapped = (parsed_photo['latitude'] == '0') ? 'false' : 'true'
          old_photo_dateadded = photo.dateadded
          photo.dateadded = Time.at(parsed_photo['dateadded'].to_i).getutc
          old_photo_lastupdate = photo.lastupdate
          photo.lastupdate = Time.at(parsed_photo['lastupdate'].to_i).getutc
          old_photo_views = photo.views
          photo.views = parsed_photo['views'].to_i
          photo.person = person
          if photo.id.nil? ||
            old_photo_farm != photo.farm ||
            old_photo_server != photo.server ||
            old_photo_secret != photo.secret ||
            old_photo_mapped != photo.mapped ||
            old_photo_dateadded != photo.dateadded ||
            old_photo_lastupdate != photo.lastupdate ||
            old_photo_views != photo.views
            photo.save!
          end

        end

        page += 1
      end
    end

    update.completed_at = Time.now.getutc
    update.save!

    return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
  end

  def self.update_seen_at(flickrids, time)
    joined_flickrids = flickrids.map { |flickrid| "'#{flickrid}'" }.join ','
    update_all "seen_at = '#{time.strftime '%Y-%m-%d %H:%M:%S'}'",
      "flickrid in (#{joined_flickrids})"
  end

  def self.update_statistics
    connection.execute %q{
      update photos p set
        member_comments =
          ifnull(
            (select count(*)
              from people poster, comments c, people commenter, guesses g
              where
                p.person_id = poster.id and
                p.id = c.photo_id and
                poster.flickrid != c.flickrid and
                c.flickrid = commenter.flickrid and
                p.id = g.photo_id and
                c.commented_at <= g.guessed_at
              group by c.photo_id),
            0),
        member_questions =
          ifnull(
            (select count(*)
              from people poster, comments c, people commenter, guesses g
              where
                p.person_id = poster.id and
                p.id = c.photo_id and
                poster.flickrid != c.flickrid and
                c.flickrid = commenter.flickrid and
                p.id = g.photo_id and
                c.commented_at <= g.guessed_at and
                c.comment_text like '%?%'
              group by c.photo_id),
            0)
    }
  end

  def self.multipoint
    photo_ids = Guess.count(:group => :photo_id).
      to_a.find_all { |pair| pair[1] > 1 }.map { |pair| pair[0] }
    Photo.find_all_by_id photo_ids,
      :include => :person, :order => "lastupdate desc"
  end

  def load_comments
    comments = []
    parsed_xml = FlickrCredentials.request 'flickr.photos.comments.getList',
      'photo_id' => flickrid
    if parsed_xml['comments']
      comments_xml = parsed_xml['comments'][0]
      if comments_xml['comment'] && ! comments_xml['comment'].empty?
        transaction do
          Comment.delete_all 'photo_id = ' + id.to_s
	  comments_xml['comment'].each do |comment_xml|
	    comment = Comment.create! \
              :photo_id => id,
              :flickrid => comment_xml['author'],
              :username => comment_xml['authorname'],
              :comment_text => comment_xml['content'],
              :commented_at => Time.at(comment_xml['datecreate'].to_i).getutc
	    comments.push comment
	  end
	end
      end
    end
    comments
  end

  def self.change_game_status(id, status)
    transaction do
      Guess.find_all_by_photo_id(id).each do |guess|
        # TODO Dave address this duplication and feature envy
        guess.destroy
        guess.person.destroy_if_has_no_dependents
      end
      Revelation.delete_all [ "photo_id = ?", id ]
      photo = find id
      photo.game_status = status
      photo.save!
    end
  end

  def self.add_answer(comment_id, username)
    transaction do
      #noinspection RailsParamDefResolve
      comment = Comment.find comment_id, :include => { :photo => [ :person, :revelation ] }
      photo = comment.photo

      if username != ''
        # TODO Dave this branch results in a guess that can't be individually removed
        guesser_flickrid = Comment.find_by_username(username).flickrid
        guesser = Person.find_by_username username
      else
        guesser_flickrid = comment.flickrid
        guesser = Person.find_by_flickrid guesser_flickrid
      end
      if !guesser
        # TODO Dave don't bother to check the username, since we'll update it when we next scrape Flickr?
        result = FlickrCredentials.request 'flickr.people.getInfo',
          'user_id' => guesser_flickrid
        guesser = Person.new
        guesser.flickrid = guesser_flickrid
        guesser.username = result['person'][0]['username'][0]
        guesser.save!
      end
      if guesser == photo.person
        photo.game_status = 'revealed'
        photo.save!

        revelation = photo.revelation
        if revelation
          revelation.revelation_text = comment.comment_text
          revelation.revealed_at = comment.commented_at
          revelation.save!
        else
          Revelation.create! \
            :photo => photo,
            :revelation_text => comment.comment_text,
            :revealed_at => comment.commented_at,
            :added_at => Time.now.getutc
        end

        # TODO Dave this probably orphans people too
        Guess.delete_all [ "photo_id = ?", photo.id ]

      else
        photo.game_status = 'found'
        photo.save!

        guess = Guess.find_by_photo_id_and_person_id photo.id, guesser.id
        if guess
          guess.guessed_at = comment.commented_at
          guess.guess_text = comment.comment_text
          guess.save!
        else
          Guess.create! \
            :photo => photo,
            :person => guesser,
            :guess_text => comment.comment_text,
            :guessed_at => comment.commented_at,
            :added_at => Time.now.getutc
        end

        Revelation.delete photo.revelation.id if photo.revelation

      end

    end
  end

  def self.remove_answer(comment_id)
    transaction do
      #noinspection RailsParamDefResolve
      comment = Comment.find comment_id, :include => { :photo => [ :person, :revelation ] }
      photo = comment.photo
      guesser = Person.find_by_flickrid comment.flickrid
      if ! guesser
        raise RemoveAnswerError, 'That comment has not been recorded as a guess or revelation.'
      end
      if guesser.id == photo.person_id
        if ! photo.revelation
          raise RemoveAnswerError, 'That comment has not been recorded as a revelation.'
        end
        photo.game_status = 'unfound'
        photo.save!
        photo.revelation.destroy
      else
        guess = Guess.find_by_person_id_and_guess_text guesser.id,
          comment.comment_text
        if ! guess
          raise RemoveAnswerError, 'That comment has not been recorded as a guess.'
        end
        guess_count = Guess.count :conditions => [ "photo_id = ?", photo.id ]
        if guess_count == 1
          photo.game_status = 'unfound'
          photo.save!
        end
        guess.destroy
        guess.person.destroy_if_has_no_dependents
      end
    end
  end

  class RemoveAnswerError < StandardError
  end

  def self.destroy_photo_and_dependent_objects(photo_id)
    transaction do
      photo = find photo_id, :include => [ :revelation, :person ]
      photo.revelation.destroy if photo.revelation
      Guess.delete_all [ 'photo_id = ?', photo.id ]
      Comment.delete_all [ 'photo_id = ?', photo.id ]
      photo.destroy
      photo.person.destroy_if_has_no_dependents
    end
  end

  # Used by Admin::GuessesController

  def self.count_since(update)
    count :conditions => [ "? <= dateadded", update.created_at ]
  end

  def self.add_posts(people)
    posts_per_person = Photo.count :group => :person_id
    people.each do |person|
      person[:posts] = posts_per_person[person.id] || 0
    end
  end

end
