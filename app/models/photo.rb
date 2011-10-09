class Photo < ActiveRecord::Base
  include Answer

  #noinspection RubyResolve
  self.include_root_in_json = false

  belongs_to :person, :inverse_of => :photos
  has_many :guesses, :inverse_of => :photo
  has_many :comments, :inverse_of => :photo
  has_one :revelation, :inverse_of => :photo
  validates_presence_of :flickrid, :dateadded, :lastupdate, :seen_at,
    :game_status, :views, :other_user_comments, :member_comments, :member_questions
  attr_readonly :person, :flickrid
  validates_numericality_of :latitude, :allow_nil => true
  validates_numericality_of :longitude, :allow_nil => true
  validates_numericality_of :accuracy, :allow_nil => true,
    :only_integer => true, :greater_than_or_equal_to => 0
  validates_inclusion_of :game_status, :in => %w(unfound unconfirmed found revealed)
  validates_numericality_of :views, :only_integer => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :other_user_comments, :only_integer => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :member_comments, :only_integer => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :member_questions, :only_integer => true,
    :greater_than_or_equal_to => 0

  # Used by ScoreReportsController

  def self.count_between(from, to)
    where('? < dateadded and dateadded <= ?', from.getutc, to.getutc).count
  end

  def self.unfound_or_unconfirmed_count_before(date)
    utc_date = date.getutc
    count_by_sql [
      %q[
        select count(*) from photos p where
          dateadded <= ? and
          not exists (select 1 from guesses where photo_id = p.id and added_at <= ?) and
          not exists (select 1 from revelations where photo_id = p.id and added_at <= ?)
        ],
        utc_date, utc_date, utc_date
    ]
  end

  def self.add_posts(people, to_date, attr_name)
    posts_per_person = where('dateadded <= ?', to_date.getutc).group(:person_id).count
    people.each do |person|
      person[attr_name] = posts_per_person[person.id] || 0
    end
  end

  # Used by PeopleController

  def self.first_by(poster)
    where(:person_id => poster).order(:dateadded).includes(:person).first
  end

  def self.most_recent_by(poster)
    where(:person_id => poster).order(:dateadded).includes(:person).last
  end

  def self.oldest_unfound(poster)
    oldest_unfound =
      includes(:person).where("person_id = ? and game_status in ('unfound', 'unconfirmed')", poster).order(:dateadded).first
    if oldest_unfound
      oldest_unfound[:place] = count_by_sql([
        %q{
          select count(*)
          from
            (
              select min(dateadded) min_dateadded
              from photos where game_status in ('unfound', 'unconfirmed')
              group by person_id
            ) oldest_unfounds
          where min_dateadded < ?
        },
        oldest_unfound.dateadded
      ]) + 1
    end
    oldest_unfound
  end

  def self.most_commented(poster)
    most_commented = includes(:person).where(:person_id => poster).order('other_user_comments desc').first
    if most_commented
      most_commented[:place] = count_by_sql([
        %q[
          select count(*)
          from (
            select max(other_user_comments) max_other_user_comments
            from photos
            group by person_id
          ) max_comments
          where max_other_user_comments > ?
        ],
        most_commented.other_user_comments
      ]) + 1
      most_commented
    else
      nil
    end
  end

  def self.most_viewed(poster)
    most_viewed = includes(:person).where(:person_id => poster).order('views desc').first
    if most_viewed
      most_viewed[:place] = count_by_sql([
        %q[
          select count(*)
          from (
            select max(views) max_views
            from photos f
            group by person_id
          ) most_viewed
          where max_views > ?
        ],
        most_viewed.views
      ]) + 1
    end
    most_viewed
  end

  def self.find_with_guesses(person)
    where(:person_id => person).includes(:guesses => :person)
  end

  def self.mapped_count(poster_id)
    where(:person_id => poster_id).where('accuracy >= 12 or inferred_latitude is not null').count
  end

  def self.posted_or_guessed_by_and_mapped(person_id, bounds, limit)
    mapped(bounds, limit).joins('left join guesses on guesses.photo_id = photos.id') \
      .where('photos.person_id = ? or guesses.person_id = ?', person_id, person_id)
  end

  # Used by PhotosController

  def self.all_sorted_and_paginated(sorted_by, order, page, per_page)
    paginate_by_sql(
      %Q[
        select p.*
          from photos p, people poster
          where p.person_id = poster.id
          order by #{order_by(sorted_by, order)}
      ],
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
    'comments' => { :secondary => [ 'username' ],
      :column => 'other_user_comments', :default_order => '-' },
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

  def self.mapped(bounds, limit)
    Photo \
      .where(
        '(accuracy >= 12 and latitude between ? and ? and longitude between ? and ?) or ' +
          '(inferred_latitude between ? and ? and inferred_longitude between ? and ?)',
          bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long,
          bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long) \
      .order('dateadded desc').limit(limit)
  end

  def self.oldest
    Photo.order('dateadded').first
  end

  def self.unfound_or_unconfirmed
    where("game_status in ('unfound', 'unconfirmed')").order('lastupdate desc').includes(:person)
  end

  # Used by WheresiesController

  def self.most_viewed_in(year)
    where('? <= dateadded and dateadded < ?', Time.local(year).getutc, Time.local(year + 1).getutc) \
      .order('views desc').limit(10).includes(:person)
  end

  def self.most_commented_in(year)
    find_by_sql [
      %q{
        select f.*, count(*) comments from photos f, people p, comments c
        where ? <= f.dateadded and f.dateadded < ? and
          f.person_id = p.id and
          f.id = c.photo_id and
          c.flickrid != p.flickrid
        group by f.id order by comments desc limit 10
      },
      Time.local(year).getutc, Time.local(year + 1).getutc ]
  end

  # Used by Admin::RootController

  def self.unfound_or_unconfirmed_count
    where("game_status in ('unfound', 'unconfirmed')").count
  end

  def self.update_all_from_flickr
    page = 1
    parsed_photos = nil
    existing_people = {}
    new_photo_count = 0
    new_person_count = 0
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      logger.info "Getting page #{page} ..."
      photos_xml = FlickrCredentials.request 'flickr.groups.pools.getPhotos',
        'per_page' => '500', 'page' => page.to_s,
        'extras' => 'geo,last_update,path_alias,views' # Note path_alias here but pathalias in the result
      parsed_photos = photos_xml['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }

      logger.info "Updating database from page #{page} ..."
      transaction do
        now = Time.now.getutc
        update_seen_at photo_flickrids, now

        people_flickrids = Set.new parsed_photos['photo'].map { |p| p['owner'] }
        existing_people_flickrids = people_flickrids - existing_people.keys
        Person.find_all_by_flickrid(existing_people_flickrids.to_a).each do |person|
          existing_people[person.flickrid] = person
        end

        existing_photos = find_all_by_flickrid(photo_flickrids).index_by &:flickrid

        parsed_photos['photo'].each do |parsed_photo|
          person_flickrid = parsed_photo['owner']
          person = existing_people[person_flickrid]
          person_attrs = { :username => parsed_photo['ownername'], :pathalias => parsed_photo['pathalias'] }
          if person
            person.update_attributes_if_necessary! person_attrs
          else
            person = Person.create! person_attrs.merge(:flickrid => person_flickrid)
            existing_people[person_flickrid] = person
            new_person_count += 1
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
          old_photo_latitude = photo.latitude
          photo.latitude = parsed_photo['latitude']
          if photo.latitude == 0.0
            photo.latitude = nil
          end
          old_photo_longitude = photo.longitude
          photo.longitude = parsed_photo['longitude']
          if photo.longitude == 0.0
            photo.longitude = nil
          end
          old_photo_accuracy = photo.accuracy
          photo.accuracy = parsed_photo['accuracy']
          if photo.accuracy == 0.0
            photo.accuracy = nil
          end
          # Don't overwrite an existing photo's dateadded, so that if a photo
          # is added, removed and added again it retains its original dateadded.
          if photo.id.nil? then
            photo.dateadded = Time.at(parsed_photo['dateadded'].to_i).getutc
          end
          old_photo_lastupdate = photo.lastupdate
          photo.lastupdate = Time.at(parsed_photo['lastupdate'].to_i).getutc
          old_photo_views = photo.views
          photo.views = parsed_photo['views'].to_i
          photo.person = person
          if photo.id.nil? ||
            old_photo_farm != photo.farm ||
            old_photo_server != photo.server ||
            old_photo_secret != photo.secret ||
            old_photo_latitude != photo.latitude ||
            old_photo_longitude != photo.longitude ||
            old_photo_accuracy != photo.accuracy ||
            old_photo_lastupdate != photo.lastupdate ||
            old_photo_views != photo.views
            photo.save!
          end

        end

        page += 1
      end
    end
    return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
  end

  # Public only for testing
  def self.update_seen_at(flickrids, time)
    joined_flickrids = flickrids.map { |flickrid| "'#{flickrid}'" }.join ','
    update_all "seen_at = '#{time.getutc.strftime '%Y-%m-%d %H:%M:%S'}'",
      "flickrid in (#{joined_flickrids})"
  end

  def self.update_statistics
    connection.execute %q{
      update photos f set
        other_user_comments =
          ifnull(
            (select count(*)
              from people poster, comments c
              where
                f.person_id = poster.id and
                f.id = c.photo_id and
                poster.flickrid != c.flickrid
              group by c.photo_id),
            0),
        member_comments =
          ifnull(
            (select count(*)
              from people poster, comments c, people commenter, guesses g
              where
                f.person_id = poster.id and
                f.id = c.photo_id and
                poster.flickrid != c.flickrid and
                c.flickrid = commenter.flickrid and
                f.id = g.photo_id and
                c.commented_at <= g.commented_at
              group by c.photo_id),
            0),
        member_questions =
          ifnull(
            (select count(*)
              from people poster, comments c, people commenter, guesses g
              where
                f.person_id = poster.id and
                f.id = c.photo_id and
                poster.flickrid != c.flickrid and
                c.flickrid = commenter.flickrid and
                f.id = g.photo_id and
                c.commented_at <= g.commented_at and
                c.comment_text like '%?%'
              group by c.photo_id),
            0)
    }
  end

  def self.infer_geocodes
    logger.info 'Inferring geocodes ...'
    start = Time.now
    answers = Guess.includes(:photo) + Revelation.includes(:photo)
    parser = LocationParser.new Stcline.multiword_street_names
    answer_count = 0
    location_count = 0
    inferred_count = 0
    answers.each do |answer|
      answer_count += 1
      logger.debug "\nInferring geocode for \"#{answer.comment_text}\" ..."
      locations = parser.parse answer.comment_text
      if locations.empty?
        logger.debug "Found no location."
      else
        location_count += 1
        shapes = locations.map { |location| Stintersection.geocode location }.reject &:nil?
        if shapes.length != 1
          logger.debug "Found #{shapes.length} geocodes."
          point = nil
        else
          inferred_count += 1
          point = shapes[0]
        end
      end
      #noinspection RubyScope
      answer.photo.save_geocode point
    end
    finish = Time.now
    logger.info "Examined #{answer_count} photos " +
      "(#{finish - start} s, #{(finish - start) / answer_count} s/photo); " +
      "found #{location_count} candidate locations (#{'%.1f' % (100.0 * location_count / answer_count)}% success); " +
      "inferred #{inferred_count} geocodes (#{'%.1f' % (100.0 * inferred_count / answer_count)}% success)"
  end

  def save_geocode(point)
    lat, long = point.nil? ? [ nil, nil ] : [ point.y, point.x ]
    if inferred_latitude != lat || inferred_longitude != long
      self.inferred_latitude = lat
      self.inferred_longitude = long
      save!
    end
  end

  # Used by Admin::PhotosController

  def self.inaccessible
    where("seen_at < ? and game_status in ('unfound', 'unconfirmed')", FlickrUpdate.latest.created_at) \
      .order('lastupdate desc').includes(:person)
  end

  def self.multipoint
    photo_ids = Guess.group(:photo_id).count \
      .to_a.find_all { |pair| pair[1] > 1 }.map { |pair| pair[0] }
    order('lastupdate desc').includes(:person).find photo_ids
  end

  def self.find_with_associations(id)
    #noinspection RailsParamDefResolve
    includes(:person, :revelation, { :guesses => :person }).find id
  end

  def load_comments
    comments = []
    parsed_xml = FlickrCredentials.request 'flickr.photos.comments.getList', 'photo_id' => flickrid
    if parsed_xml['comments']
      comments_xml = parsed_xml['comments'][0]
      if comments_xml['comment'] && ! comments_xml['comment'].empty?
        transaction do
          Comment.where(:photo_id => id).delete_all
	        comments_xml['comment'].each do |comment_xml|
            comments << Comment.create!(
              :photo_id => id,
              :flickrid => comment_xml['author'],
              :username => comment_xml['authorname'],
              :comment_text => comment_xml['content'],
              :commented_at => Time.at(comment_xml['datecreate'].to_i).getutc)
          end
          return comments
	      end
      end
    end
    self.comments
  end

  def self.change_game_status(id, status)
    transaction do
      Guess.destroy_all_by_photo_id id
      Revelation.where(:photo_id => id).delete_all
      photo = find id
      photo.game_status = status
      photo.save!
    end
  end

  def self.add_entered_answer(photo_id, username, answer_text)
    if answer_text.empty?
      raise ArgumentError, 'answer_text may not be empty'
    end

    #noinspection RailsParamDefResolve
    photo = Photo.includes(:person, :revelation).find photo_id
    if username.empty?
      username = photo.person.username
    end
    photo.answer nil, nil, username, answer_text, Time.now.getutc

  end

  def answer(selected_username, selected_flickrid, entered_username, answer_text, answered_at)
    guesser = nil
    if entered_username.empty?
      guesser_username = selected_username
      guesser_flickrid = selected_flickrid
    else
      guesser_username = entered_username
      guesser_flickrid = nil
      if entered_username == self.person.username
        guesser_flickrid = self.person.flickrid
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

    transaction do
      if guesser_flickrid == self.person.flickrid
        reveal answer_text, answered_at
      else
        guess(answer_text, answered_at, guesser_flickrid, guesser_username, guesser)
      end
    end

  end

  class AddAnswerError < StandardError
  end

  def reveal(answer_text, answered_at)
    self.game_status = 'revealed'
    self.save!

    revelation = self.revelation
    if revelation
      revelation.comment_text = answer_text
      revelation.commented_at = answered_at
      revelation.added_at = Time.now.getutc
      revelation.save!
    else
      Revelation.create! \
        :photo => self,
        :comment_text => answer_text,
        :commented_at => answered_at,
        :added_at => Time.now.getutc
    end

    Guess.destroy_all_by_photo_id self.id
  end
  private :reveal

  # guesser is present only for performance. It may be nil.
  # If non-nil, it has the given guesser_flickrid and guesser_username.
  def guess(answer_text, answered_at, guesser_flickrid, guesser_username, guesser)
    self.game_status = 'found'
    self.save!

    if !guesser then
      guesser = Person.find_by_flickrid guesser_flickrid
    end
    if guesser
      # TODO Dave update person's username and pathalias
      guess = Guess.find_by_photo_id_and_person_id self.id, guesser.id
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
        :photo => self,
        :person => guesser,
        :comment_text => answer_text,
        :commented_at => answered_at,
        :added_at => Time.now.getutc
    end

    self.revelation.destroy if self.revelation
  end
  private :guess

  def self.destroy_photo_and_dependent_objects(photo_id)
    transaction do
      #noinspection RailsParamDefResolve
      photo = includes(:revelation, :person).find photo_id
      photo.revelation.destroy if photo.revelation
      Guess.destroy_all_by_photo_id photo.id
      Comment.where(:photo_id => photo).delete_all
      photo.destroy
    end
  end

  def destroy
    super
    person.destroy_if_has_no_dependents
  end

  # Miscellaneous instance methods

  def years_old
    ((Time.now - dateadded).to_i / (365 * 24 * 60 * 60)).truncate
  end

  def star_for_age
    age = years_old
    if age >= 3
      :gold
    elsif age >= 2
      :silver
    elsif age >= 1
      :bronze
    else
      nil
    end
  end

  def time_elapsed
    time_elapsed_between dateadded, Time.now
  end

  def ymd_elapsed
    ymd_elapsed_between dateadded, Time.now
  end

  def star_for_comments
    if other_user_comments >= 30
      :gold
    elsif other_user_comments >= 20
      :silver
    else
      nil
    end
  end

  def star_for_views
    if views >= 3000
      :gold
    elsif views >= 1000
      :silver
    elsif views >= 300
      :bronze
    else
      nil
    end
  end

  def mapped?
    (accuracy && accuracy >= 12) ? true : false
  end

  def mapped_or_automapped?
    mapped? || ! inferred_latitude.nil?
  end

end
