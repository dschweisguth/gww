class Photo < ActiveRecord::Base
  include Answer, PhotoStatisticsSupport, PhotoWheresiesSupport

  belongs_to :person, inverse_of: :photos
  has_many :comments, inverse_of: :photo, dependent: :destroy
  has_many :tags, -> { order :id }, inverse_of: :photo, dependent: :destroy
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
    where("dateadded <= ?", utc_date)
      .where("not exists (select 1 from guesses where photo_id = photos.id and added_at <= ?)", utc_date)
      .where("not exists (select 1 from revelations where photo_id = photos.id and added_at <= ?)", utc_date)
      .count
  end

  def self.add_posts(people, to_date, attr_name)
    posts_per_person = where('dateadded <= ?', to_date.getutc).group(:person_id).count
    people.each do |person|
      person.send "#{attr_name}=", (posts_per_person[person.id] || 0)
    end
  end

  # Used by PeopleController

  def self.posted_or_guessed_by_and_mapped(person_id, bounds, limit)
    mapped(bounds, limit).joins('left join guesses on guesses.photo_id = photos.id')
      .where('photos.person_id = ? or guesses.person_id = ?', person_id, person_id)
  end

  def has_obsolete_tags?
    if %w(found revealed).include?(game_status)
      raws = tags.map { |tag| tag.raw.downcase }
      raws.include?('unfoundinsf') &&
        ! (raws.include?('foundinsf') || game_status == 'revealed' && raws.include?('revealedinsf'))
    end
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
    Photo
      .where(
        '(accuracy >= 12 and latitude between ? and ? and longitude between ? and ?) or ' +
          '(inferred_latitude between ? and ? and inferred_longitude between ? and ?)',
          bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long,
          bounds.min_lat, bounds.max_lat, bounds.min_long, bounds.max_long)
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
    if terms.has_key? 'game-status'
      query = query.where game_status: terms['game-status']
    end
    if terms.has_key? 'posted-by'
      query = query.joins(:person).where people: { username: terms['posted-by'] }
    end
    if terms['text']
      terms['text'].each do |words|
        clauses = [
          "title regexp ?",
          "description regexp ?",
          "exists (select 1 from tags t where photos.id = t.photo_id and lower(t.raw) regexp ?)"
        ]
        sql = clauses.map { |clause| Array.new(words.length) { clause }.join(" and ") + " or " }.join +
          "exists (select 1 from comments c where photos.id = c.photo_id and (#{Array.new(words.length) { "c.comment_text regexp ?" }.join " and " }))"
        query = query.where(sql, *Array.new(clauses.length + 1, words).flatten.map { |word| "[[:<:]]#{word.downcase}[[:>:]]" })
          .includes :tags, :comments # because we display them when it's a text search
      end
    end
    if terms.has_key? 'from-date'
      query = query.where "? <= dateadded", Date.parse_utc_time(terms['from-date'])
    end
    if terms.has_key? 'to-date'
      query = query.where "dateadded < ?", Date.parse_utc_time(terms['to-date']) + 1.day
    end
    query
      .order("#{sorted_by == 'date-added' ? 'dateadded' : 'lastupdate'} #{direction == '+' ? 'asc' : 'desc'}")
      .includes(:person)
      .paginate page: page, per_page: 30
  end

  def comments_that_match(text_term_groups)
    comments.select { |comment| text_term_groups.any? { |terms| terms.all? { |text| comment.comment_text =~ /\b#{text}\b/i } } }
  end

  def human_tags
    tags.select { |tag| !tag.machine_tag }
  end

  def machine_tags
    tags.select &:machine_tag
  end

  # Used by Admin::RootController

  def self.unfound_or_unconfirmed_count
    where("game_status in ('unfound', 'unconfirmed')").count
  end

  def self.inaccessible_count
    where("seen_at < ?", FlickrUpdate.maximum(:created_at)).where("game_status in ('unfound', 'unconfirmed')").count
  end

  def self.multipoint_count
    connection.execute("select count(*) from (#{multipoint_without_associations.to_sql}) rows").first.first.to_i
  end

  # Used by Admin::PhotosController

  def self.inaccessible
    where("seen_at < ?", FlickrUpdate.latest.created_at)
      .where("game_status in ('unfound', 'unconfirmed')")
      .order('lastupdate desc')
      .includes(:person, :tags)
  end

  def self.multipoint
    multipoint_without_associations.order('lastupdate desc').includes(:person, :tags)
  end

  def self.multipoint_without_associations
    joins(:guesses).group("photos.id").having("count(*) > 1")
  end

  def ready_to_score?
    %w(unfound unconfirmed).include?(game_status) && tags.any? { |tag| %w(foundinsf revealedinsf).include? tag.raw.downcase }
  end

  GAME_STATUS_TAGS = %w(unfoundinsf foundinsf revealedinsf)

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

  def replace_comments(attributes_hashes)
    transaction do
      comments.clear
      attributes_hashes.each { |attributes| comments.create! attributes }
    end
  end

  def replace_tags(attributes_hashes)
    transaction do
      tags.clear
      attributes_hashes.each { |attributes| tags.create! attributes }
    end
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
