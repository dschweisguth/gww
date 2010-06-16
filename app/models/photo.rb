class Photo < ActiveRecord::Base
  belongs_to :person
  has_many :guesses
  has_many :comments
  has_one :revelation

  def self.update_seen_at(flickrids, time)
    joined_flickrids = flickrids.map { |flickrid| "'#{flickrid}'" }.join ','
    Photo.update_all "seen_at = '#{time.strftime '%Y-%m-%d %H:%M:%S'}'",
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

  ORDER_BY_CLAUSE = {
    'username' => 
      { :column => 'lower(poster.username)', :default_order => '+' },
    'date-added' => 
      { :column => 'dateadded', :default_order => '-' },
    'last-updated' => 
      { :column => 'lastupdate', :default_order => '-' },
    'views' => 
      { :column => 'views', :default_order => '-' },
    'member-comments' => 
      { :column => 'member_comments', :default_order => '-' },
    'member-questions' => 
      { :column => 'member_questions', :default_order => '-' }
  }

  def self.clause(sorted_by, order)
    clause = ORDER_BY_CLAUSE[sorted_by][:column]
    if ORDER_BY_CLAUSE[sorted_by][:default_order] != order
      clause += ' desc'
    end
    clause
  end

  def self.all_with_stats(sorted_by, order, page, per_page)
    order_by = (
      case sorted_by
      when 'username'
        clause('username', order) + ', ' + clause('date-added', order)
      when 'date-added'
        clause('date-added', order) + ', ' + clause('username', order)
      when 'last-updated'
        clause('last-updated', order) + ', ' + clause('username', order)
      when 'views'
	clause('views', order) + ', ' + clause('username', order)
      when 'member-comments'
	clause('member-comments', order) + ', ' +
	  clause('date-added', order) + ', ' + clause('username', order)
      when 'member-questions'
	clause('member-questions', order) + ', ' +
	  clause('date-added', order) + ', ' + clause('username', order)
      end
    )
    Photo.paginate_by_sql(
      'select p.* ' +
        'from photos p, people poster ' +
        'where p.person_id = poster.id ' +
        'order by ' + order_by,
      :page => page, :per_page => per_page)
  end

  def self.unfound_or_unconfirmed
    Photo.find :all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc"
  end

end
