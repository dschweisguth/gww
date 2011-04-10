class Photo < ActiveRecord::Base
  include Answer

  belongs_to :person, :inverse_of => :photos
  has_many :guesses, :inverse_of => :photo
  has_many :comments, :inverse_of => :photo
  has_one :revelation, :inverse_of => :photo
  validates_presence_of :flickrid, :dateadded, :lastupdate, :seen_at,
    :game_status, :views, :member_comments, :member_questions
  attr_readonly :person, :flickrid
  validates_numericality_of :latitude, :allow_nil => true
  validates_numericality_of :longitude, :allow_nil => true
  validates_numericality_of :accuracy, :allow_nil => true,
    :only_integer => true, :greater_than_or_equal_to => 0
  validates_inclusion_of :game_status, :in => %w(unfound unconfirmed found revealed)
  validates_numericality_of :views, :only_integer => true,
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
    where(:person_id => poster).order(:dateadded).first
  end

  def self.most_recent_by(poster)
    where(:person_id => poster).order(:dateadded).last
  end

  def self.oldest_unfound(poster)
    oldest_unfound =
      where("person_id = ? and game_status in ('unfound', 'unconfirmed')", poster).order(:dateadded).first
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
    most_commented = find_by_sql [
      %q[
          select f.*, count(*) comment_count
          from photos f, comments c
          where
            f.person_id = ? and
            f.id = c.photo_id and
            c.flickrid != ?
          group by f.id
          order by comment_count desc 
          limit 1
      ],
      poster.id, poster.flickrid
    ]
    if ! most_commented.empty? then
      most_commented = most_commented[0]
      most_commented[:place] = count_by_sql([
        %q[
        select count(*)
        from (
          select max(comment_count) max_comment_count
          from (
            select p.id, count(*) comment_count from photos f, people p, comments c
            where f.person_id = p.id and
              f.id = c.photo_id and
              p.flickrid != c.flickrid
            group by f.id
          ) comment_counts
          group by id
        ) max_comment_counts
        where max_comment_count > ?
      ], most_commented[:comment_count]
      ]) + 1
      most_commented
    else
      nil
    end
  end

  def self.most_viewed(poster)
    most_viewed = where(:person_id => poster).order('views desc').first
    if most_viewed then
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

  def self.mapped_count(poster_id)
    where('person_id = ? and accuracy >= 12', poster_id).count
  end
  
  def self.all_mapped(poster_id)
    where('person_id = ? and accuracy >= 12', poster_id).order(:dateadded)
  end

  # Used by PhotosController

  def self.all_sorted_and_paginated(sorted_by, order, page, per_page)
    paginate_by_sql \
      %Q[
        select p.*
          from photos p, people poster
          where p.person_id = poster.id
          order by #{order_by(sorted_by, order)}
      ],
      :page => page, :per_page => per_page
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

    update.completed_at = Time.now.getutc
    update.save!

    return new_photo_count, new_person_count, page - 1, parsed_photos['pages'].to_i
  end

  def self.update_seen_at(flickrids, time)
    joined_flickrids = flickrids.map { |flickrid| "'#{flickrid}'" }.join ','
    update_all "seen_at = '#{time.getutc.strftime '%Y-%m-%d %H:%M:%S'}'",
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
                c.commented_at <= g.commented_at
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
                c.commented_at <= g.commented_at and
                c.comment_text like '%?%'
              group by c.photo_id),
            0)
    }
  end

  def self.inaccessible
    where("seen_at < ? and game_status in ('unfound', 'unconfirmed')", FlickrUpdate.latest.created_at) \
      .order('lastupdate desc').includes(:person)
  end

  def self.multipoint
    photo_ids = Guess.group(:photo_id).count \
      .to_a.find_all { |pair| pair[1] > 1 }.map { |pair| pair[0] }
    order('lastupdate desc').includes(:person).find photo_ids
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

  def self.destroy_photo_and_dependent_objects(photo_id)
    transaction do
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

  def self.infer_geocodes
    logger.info 'Inferring geocodes ...'
    parser = LocationParser.new Stcline.street_names
    guesses = Guess.limit 100
    start = Time.now
    guess_count = 0
    location_count = 0
    inferred_count = 0
    guesses.each do |guess|
      guess_count += 1
      logger.info "Inferring geocode for \"#{guess.comment_text}\" ..."
      photo = guess.photo
      photo.inferred_latitude = nil
      photo.inferred_longitude = nil
      location = parser.parse guess.comment_text
      if location.valid
        location_count += 1
        shape = Stnode.geocode location
        if shape
          inferred_count += 1
          photo.inferred_latitude = shape.x
          photo.inferred_longitude = shape.y
        end
      else
        logger.info "Found no location."
      end
      photo.save!
    end
    finish = Time.now
    logger.info "Examined #{guess_count} photos " +
      "(#{finish - start} s, #{(finish - start) / guess_count} s/photo); " +
      "found #{location_count} candidate locations; " +
      "inferred #{inferred_count} geocodes (#{'%.1f' % (100.0 * inferred_count / guess_count)}% success)"
  end

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
    if self[:comment_count] >= 30
      :gold
    elsif self[:comment_count] >= 20
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

end
