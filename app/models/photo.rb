class Photo < ActiveRecord::Base
  include Answer, UpdatableOnlyIfNecessary

  #noinspection RubyResolve
  self.include_root_in_json = false

  belongs_to :person, inverse_of: :photos
  has_many :guesses, inverse_of: :photo
  has_many :comments, inverse_of: :photo
  has_one :revelation, inverse_of: :photo
  validates_presence_of :flickrid, :dateadded, :lastupdate, :seen_at,
    :game_status, :views, :faves, :other_user_comments, :member_comments, :member_questions
  attr_readonly :person, :flickrid
  validates_numericality_of :latitude, allow_nil: true
  validates_numericality_of :longitude, allow_nil: true
  validates_numericality_of :accuracy, allow_nil: true, only_integer: true, greater_than_or_equal_to: 0
  validates_inclusion_of :game_status, in: %w(unfound unconfirmed found revealed)
  validates_numericality_of :views, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :faves, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :other_user_comments, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :member_comments, only_integer: true, greater_than_or_equal_to: 0
  validates_numericality_of :member_questions, only_integer: true, greater_than_or_equal_to: 0

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
    where(person_id: poster).order(:dateadded).includes(:person).first
  end

  def self.most_recent_by(poster)
    where(person_id: poster).order(:dateadded).includes(:person).last
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
    most_commented = includes(:person).where(person_id: poster).order('other_user_comments desc').first
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
    most_viewed = includes(:person).where(person_id: poster).order('views desc').first
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

  def self.most_faved(poster)
    most_faved = includes(:person).where(person_id: poster).order('faves desc').first
    if most_faved
      most_faved[:place] = count_by_sql([
        %q[
          select count(*)
          from (
            select max(faves) max_faves
            from photos f
            group by person_id
          ) most_faved
          where max_faves > ?
        ],
        most_faved.faves
      ]) + 1
    end
    most_faved
  end

  def self.find_with_guesses(person)
    where(person_id: person).includes(guesses: :person)
  end

  def self.mapped_count(poster_id)
    where(person_id: poster_id).where('accuracy >= 12 or inferred_latitude is not null').count
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
      page: page, per_page: per_page)
  end

  SORTED_BY = {
    'username' => { secondary: [ 'date-added' ],
      column: 'lower(poster.username)', default_order: '+' },
    'date-added' => { secondary: [ 'username' ],
      column: 'dateadded', default_order: '-' },
    'last-updated' => { secondary: [ 'username' ],
      column: 'lastupdate', default_order: '-' },
    'views' => { secondary: [ 'username' ],
      column: 'views', default_order: '-' },
    'faves' => { secondary: [ 'username' ],
      column: 'faves', default_order: '-' },
    'comments' => { secondary: [ 'username' ],
      column: 'other_user_comments', default_order: '-' },
    'member-comments' => { secondary: [ 'date-added', 'username' ],
      column: 'member_comments', default_order: '-' },
    'member-questions' => { secondary: [ 'date-added', 'username' ],
      column: 'member_questions', default_order: '-' }
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

  def self.search(terms, sorted_by, direction, page)
    sql = ""
    conditions = [ sql ]
    if terms.has_key? 'game_status'
      sql << "game_status in (?)"
      conditions << terms['game_status']
    end
    if terms.has_key? 'posted_by'
      unless sql.blank?
        sql << " and "
      end
      sql << "p.username = ?"
      conditions << terms['posted_by']
    end
    args = {
      joins: "join people p on photos.person_id = p.id",
      conditions: conditions,
      order: "#{sorted_by == 'date-added' ? 'dateadded' : 'lastupdate'} #{direction == '+' ? 'asc' : 'desc'}",
      per_page: 30,
      page: page,
      include: :person
    }
    Photo.paginate args
  end

  # Used by WheresiesController

  def self.most_viewed_in(year)
    where('? <= dateadded and dateadded < ?', Time.local(year).getutc, Time.local(year + 1).getutc) \
      .order('views desc').limit(10).includes(:person)
  end

  def self.most_faved_in(year)
    where('? <= dateadded and dateadded < ?', Time.local(year).getutc, Time.local(year + 1).getutc) \
      .order('faves desc').limit(10).includes(:person)
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

  # TODO Dave count and report Flickr API calls
  def self.update_all_from_flickr
    page = 1
    parsed_photos = nil
    existing_people = {}
    new_photo_count = 0
    new_person_count = 0
    while parsed_photos.nil? || page <= parsed_photos['pages'].to_i
      logger.info "Getting page #{page} ..."
      photos_xml = FlickrService.instance.groups_pools_get_photos 'group_id' => FlickrService::GROUP_ID,
        'per_page' => '500', 'page' => page.to_s, 'extras' => 'geo,last_update,path_alias,views' # Note path_alias here but pathalias in the result
      parsed_photos = photos_xml['photos'][0]
      photo_flickrids = parsed_photos['photo'].map { |p| p['id'] }

      logger.info "Updating database from page #{page} ..."

      people_flickrids = Set.new parsed_photos['photo'].map { |p| p['owner'] }
      existing_people_flickrids = people_flickrids - existing_people.keys
      Person.find_all_by_flickrid(existing_people_flickrids.to_a).each do |person|
        existing_people[person.flickrid] = person
      end

      existing_photos = find_all_by_flickrid(photo_flickrids).index_by &:flickrid

      now = Time.now.getutc

      parsed_photos['photo'].each do |parsed_photo|
        person_flickrid = parsed_photo['owner']
        person_attrs = { username: parsed_photo['ownername'], pathalias: parsed_photo['pathalias'] }
        if person_attrs[:pathalias] == ''
          person_attrs[:pathalias] = person_flickrid
        end
        person = existing_people[person_flickrid]
        if person
          person.update_attributes_if_necessary! person_attrs
        else
          person = Person.create!({ flickrid: person_flickrid }.merge person_attrs)
          existing_people[person_flickrid] = person
          new_person_count += 1
        end

        photo_flickrid = parsed_photo['id']
        photo_attrs = {
          farm: parsed_photo['farm'],
          server: parsed_photo['server'],
          secret: parsed_photo['secret'],
          latitude: to_float_or_nil(parsed_photo['latitude']),
          longitude: to_float_or_nil(parsed_photo['longitude']),
          accuracy: to_integer_or_nil(parsed_photo['accuracy']),
          lastupdate: Time.at(parsed_photo['lastupdate'].to_i).getutc,
          views: parsed_photo['views'].to_i
        }
        photo = existing_photos[photo_flickrid]
        if ! photo || photo.lastupdate != photo_attrs[:lastupdate]
          begin
            photo_attrs[:faves] = faves_from_flickr photo_flickrid
          rescue FlickrService::FlickrRequestFailedError
            # This happens when a photo is private but visible to the caller because it's posted to a group of which
            # the caller is a member. Not clear yet whether this is a bug or intended behavior.
            photo_attrs[:faves] ||= 0
          end
        end
        if photo
          photo.update_attributes_if_necessary! photo_attrs
        else
          # Set dateadded only when a photo is created, so that if a photo is added to the group,
          # removed from the group and added to the group again it retains its original dateadded.
          Photo.create!({
            person_id: person.id,
            flickrid: photo_flickrid,
            dateadded: Time.at(parsed_photo['dateadded'].to_i).getutc,
            seen_at: now,
            game_status: 'unfound'
          }.merge photo_attrs)
          new_photo_count += 1
        end

      end

      # Update seen_at after processing the entire page so that if there's an error seen_at won't have been updated for
      # photos that didn't get processed. Having photos updated except for seen_at is not so bad, so we live with that
      # chance instead of putting it all in a very long transaction.
      update_seen_at photo_flickrids, now

      page += 1
    end
    return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
  end

  # Public only for testing
  def self.update_seen_at(flickrids, time)
    joined_flickrids = flickrids.map { |flickrid| "'#{flickrid}'" }.join ','
    update_all "seen_at = '#{time.getutc.strftime '%Y-%m-%d %H:%M:%S'}'",
      "flickrid in (#{joined_flickrids})"
  end

  def self.to_float_or_nil(string)
    number = string.to_f
    number == 0.0 ? nil : number
  end
  private_class_method :to_float_or_nil

  def self.to_integer_or_nil(string)
    number = string.to_i
    number == 0 ? nil : number
  end
  private_class_method :to_integer_or_nil

  def self.faves_from_flickr(photo_flickrid)
    faves_count = 0
    faves_page = 1
    parsed_faves = nil
    while parsed_faves.nil? || faves_page <= parsed_faves['pages'].to_i
      sleep 1.1
      faves_xml = FlickrService.instance.photos_get_favorites(
          'photo_id' => photo_flickrid, 'per_page' => '50', 'page' => faves_page.to_s)
      parsed_faves = faves_xml['photo'][0]
      faves_count += parsed_faves['person'] ? parsed_faves['person'].length : 0
      faves_page += 1
    end
    faves_count
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
      point =
        if locations.empty?
          logger.debug "Found no location."
          nil
        else
          location_count += 1
          shapes = locations.map { |location| Stintersection.geocode location }.reject &:nil?
          if shapes.length != 1
            logger.debug "Found #{shapes.length} geocodes."
            nil
          else
            inferred_count += 1
            shapes[0]
          end
        end
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
    includes(:person, :revelation, { guesses: :person }).find id
  end

  def update_from_flickr
    # TODO Dave update the photo and poster, too

    begin
      faves = Photo.faves_from_flickr self.flickrid
      if faves != self.faves
        update_attribute :faves, faves
      end
    rescue FlickrService::FlickrRequestFailedError
      # This happens when a photo is private but visible to the caller because it's posted to a group of which
      # the caller is a member. Not clear yet whether this is a bug or intended behavior.
    end

    begin
      comments_xml = FlickrService.instance.photos_comments_get_list 'photo_id' => flickrid
      parsed_comments = comments_xml['comments'][0]['comment']
      if ! parsed_comments.blank? # This element is nil if there are no comments and an array if there are
        transaction do
          Comment.where(photo_id: id).delete_all
          parsed_comments.each do |comment_xml|
            self.comments.create!(
              flickrid: comment_xml['author'],
              username: comment_xml['authorname'],
              comment_text: comment_xml['content'],
              commented_at: Time.at(comment_xml['datecreate'].to_i).getutc)
          end
        end
      end
    rescue FlickrService::FlickrRequestFailedError
      # This happens when a photo has been removed from the group.
    end

  end

  def self.change_game_status(id, status)
    transaction do
      Guess.destroy_all_by_photo_id id
      Revelation.where(photo_id: id).delete_all
      find(id).update_attribute :game_status, status
    end
  end

  def self.add_entered_answer(photo_id, username, answer_text)
    if answer_text.empty?
      raise ArgumentError, 'answer_text may not be empty'
    end

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
        guess answer_text, answered_at, guesser_flickrid, guesser_username, guesser
      end
    end

  end

  class AddAnswerError < StandardError
  end

  def reveal(comment_text, commented_at)
    update_attribute :game_status, 'revealed'

    revelation_attrs = { comment_text: comment_text, commented_at: commented_at, added_at: Time.now.getutc }
    if self.revelation
      self.revelation.update_attributes! revelation_attrs
    else
      Revelation.create!({ photo: self }.merge revelation_attrs)
    end

    self.guesses.destroy_all

  end
  private :reveal

  # guesser is present only for performance. It may be nil.
  # If non-nil, it has the given guesser_flickrid and guesser_username.
  def guess(comment_text, commented_at, guesser_flickrid, guesser_username, guesser)
    update_attribute :game_status, 'found'

    if !guesser then
      guesser = Person.find_by_flickrid guesser_flickrid
    end
    guesser_attrs =
      begin
        Person.attrs_from_flickr guesser_flickrid
      rescue FlickrService::FlickrRequestFailedError
        { username: guesser_username }
      end
    if guesser
      guesser.update_attributes_if_necessary! guesser_attrs
      guess = Guess.find_by_photo_id_and_person_id self.id, guesser.id
    else
      guesser = Person.create!({flickrid: guesser_flickrid }.merge guesser_attrs)
      guess = nil
    end
    guess_attrs = { commented_at: commented_at, comment_text: comment_text, added_at: Time.now.getutc }
    if guess
      guess.update_attributes! guess_attrs
    else
      Guess.create!({ photo: self, person: guesser }.merge guess_attrs)
    end

    self.revelation.destroy if self.revelation
    
  end
  private :guess

  def self.destroy_photo_and_dependent_objects(photo_id)
    transaction do
      photo = includes(:revelation, :person).find photo_id
      photo.revelation.destroy if photo.revelation
      Guess.destroy_all_by_photo_id photo.id
      Comment.where(photo_id: photo).delete_all
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

  def star_for_faves
    if faves >= 100
      :gold
    elsif faves >= 30
      :silver
    elsif faves >= 10
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
