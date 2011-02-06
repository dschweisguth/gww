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

  def self.unfound_or_unconfirmed_count
    count :conditions => "game_status in ('unfound', 'unconfirmed')"
  end

  def self.unfound_or_unconfirmed
    all :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc"
  end

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

  def self.count_since(update)
    count :conditions => [ "? <= dateadded", update.created_at ]
  end

  def self.add_posts(people)
    posts_per_person = Photo.count :group => :person_id
    people.each do |person|
      person[:posts] = posts_per_person[person.id] || 0
    end
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
	    comment = Comment.new
	    comment.comment_text = comment_xml['content']
	    comment.commented_at =
              Time.at(comment_xml['datecreate'].to_i).getutc
	    comment.username = comment_xml['authorname']
	    comment.flickrid = comment_xml['author']
	    comment.photo_id = id
	    comment.save!
	    comments.push comment
	  end
	end
      end
    end
    comments
  end

end
