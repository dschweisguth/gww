class Photo < ActiveRecord::Base
  include Answer

  belongs_to :person, inverse_of: :photos
  has_many :comments, inverse_of: :photo, dependent: :destroy
  has_many :tags, inverse_of: :photo, dependent: :destroy
  has_many :guesses, inverse_of: :photo, dependent: :destroy
  has_one :revelation, inverse_of: :photo, dependent: :destroy
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

  # Not persisted, used in views
  attr_accessor :color, :symbol, :place

  after_destroy do
    person.destroy_if_has_no_dependents
  end

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
      person.send "#{attr_name}=", (posts_per_person[person.id] || 0)
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
      oldest_unfound.place = count_by_sql([
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
      most_commented.place = count_by_sql([
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
      most_viewed.place = count_by_sql([
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
      most_faved.place = count_by_sql([
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

  private_class_method def self.order_by(sorted_by, order)
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
    where("game_status in ('unfound', 'unconfirmed')").order('lastupdate desc').includes(:person, :tags)
  end

  def self.search(terms, sorted_by, direction, page)
    query = all
    if terms.has_key? 'game_status'
      query = query.where game_status: terms['game_status']
    end
    if terms.has_key? 'posted_by'
      query = query.joins(:person).where people: { username: terms['posted_by'] }
    end
    query
      .order("#{sorted_by == 'date-added' ? 'dateadded' : 'lastupdate'} #{direction == '+' ? 'asc' : 'desc'}")
      .includes(:person)
      .paginate page: page, per_page: 30
  end

  def human_tags
    tags.where(machine_tag: false).order :id
  end

  def machine_tags
    tags.where(machine_tag: true).order :id
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
    where("seen_at < ?", FlickrUpdate.latest.created_at)
      .where("game_status in ('unfound', 'unconfirmed')")
      .order('lastupdate desc')
      .includes(:person, :tags)
  end

  def self.multipoint
    photo_ids = Guess.group(:photo_id).count.to_a.find_all { |pair| pair[1] > 1 }.map { |pair| pair[0] }
    order('lastupdate desc').includes(:person, :tags).find photo_ids
  end

  GAME_STATUS_TAGS = %w(unfoundinsf foundinsf revealedinsf)

  def ready_to_score?
    %w(unfound unconfirmed).include?(game_status) && tags.any? { |tag| %w(foundinsf revealedinsf).include? tag.raw.downcase }
  end

  def game_status_tags
    tags.select { |tag| GAME_STATUS_TAGS.include?(tag.raw.downcase) }.sort_by { |tag| GAME_STATUS_TAGS.index tag.raw.downcase }
  end

  def self.find_with_associations(id)
    includes(:person, :revelation, { guesses: :person }).find id
  end

  def self.change_game_status(id, status)
    transaction do
      Guess.destroy_all_by_photo_id id
      Revelation.where(photo_id: id).destroy_all
      find(id).update! game_status: status
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
    photo.answer nil, username, answer_text, Time.now.getutc

  end

  def answer(selected_flickrid, entered_username, answer_text, answered_at)
    guesser_flickrid =
      if entered_username.empty?
        selected_flickrid
      else
        Person.find_by_username(entered_username).try(:flickrid) ||
        Comment.find_by_username(entered_username).try(:flickrid) ||
        raise(AddAnswerError,
          "Sorry; GWW hasn't seen any posts or comments by #{entered_username} yet, " +
            "so doesn't know enough about them to award them a point. " +
            "Did you spell their username correctly?")
      end
    transaction do
      if guesser_flickrid == self.person.flickrid
        reveal answer_text, answered_at
      else
        guess answer_text, answered_at, guesser_flickrid
      end
    end
  end

  class AddAnswerError < StandardError
  end

  private def reveal(comment_text, commented_at)
    update! game_status: 'revealed'

    revelation_attrs = { comment_text: comment_text, commented_at: commented_at, added_at: Time.now.getutc }
    if self.revelation
      self.revelation.update! revelation_attrs
    else
      Revelation.create!({ photo: self }.merge revelation_attrs)
    end

    self.guesses.destroy_all

  end

  private def guess(comment_text, commented_at, guesser_flickrid)
    update! game_status: 'found'
    guesser = FlickrUpdater.create_or_update_person guesser_flickrid
    Guess.create! photo: self, person: guesser, commented_at: commented_at, comment_text: comment_text, added_at: Time.now.getutc
    self.revelation.try :destroy
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
