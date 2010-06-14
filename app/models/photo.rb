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

  def self.all_with_stats(sorted_by, page, per_page)
    order = (
      case sorted_by
      when 'username'
        'lower(poster.username), dateadded desc'
      when 'date-added'
        'dateadded desc, lower(poster.username)'
      when 'last-updated'
        'lastupdate desc, lower(poster.username)'
      when 'views'
        'views desc, dateadded desc, lower(poster.username)'
      when 'member-comments'
	'member_comments desc, dateadded desc, lower(poster.username)'
      when 'member-questions'
	'member_questions desc, dateadded desc, lower(poster.username)'
      end
    )
    Photo.paginate_by_sql(
      'select p.*, ' +
        '(select count(*) ' +
          'from comments c, people commenter, guesses g ' +
          'where ' +
            'p.id = c.photo_id and ' +
            'poster.flickrid != c.flickrid and ' +
            'c.flickrid = commenter.flickrid and ' + # count only member comments
            'p.id = g.photo_id and ' +
            'c.commented_at <= g.guessed_at ' +
          'group by c.photo_id) member_comments, ' +
        '(select count(*) ' +
          'from comments c, people commenter, guesses g ' +
          'where ' +
            'p.id = c.photo_id and ' +
            'poster.flickrid != c.flickrid and ' +
            'c.flickrid = commenter.flickrid and ' + # count only member comments
            'p.id = g.photo_id and ' +
            'c.commented_at <= g.guessed_at and ' +
            'c.comment_text like \'%?%\' ' +
          'group by c.photo_id) member_questions ' +
        'from photos p, people poster ' +
        'where p.person_id = poster.id ' +
        'order by ' + order,
      :page => page, :per_page => per_page)
  end

  def self.unfound_or_unconfirmed
    Photo.find :all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc"
  end

end
