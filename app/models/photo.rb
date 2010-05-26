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

  def self.unfound_or_unconfirmed
    Photo.find :all,
      :conditions => "game_status in ('unfound', 'unconfirmed')",
      :include => :person, :order => "lastupdate desc"
  end

  def self.most_commented_on(page, per_page)
    Photo.paginate_by_sql(
      'select ph.*, count(*) comment_count ' +
	'from photos ph, people poster, comments c, people commenter, ' +
          'guesses g ' +
	'where ' +
	  'ph.person_id = poster.id and ' +
	  'ph.id = c.photo_id and ' +
	  'poster.flickrid != c.flickrid and ' +
          'c.flickrid = commenter.flickrid and ' + # count only member comments
          'ph.id = g.photo_id and ' +
          'c.commented_at <= g.guessed_at ' +
	'group by ph.id ' +
	'order by count(*) desc, ph.dateadded',
      :page => page, :per_page => per_page)
  end

  def self.most_questioned(page, per_page)
    Photo.paginate_by_sql(
      'select ph.*, count(*) comment_count ' +
        'from photos ph, people poster, comments c, people commenter, ' +
          'guesses g ' +
	'where ' +
	  'ph.person_id = poster.id and ' +
	  'ph.id = c.photo_id and ' +
	  'poster.flickrid != c.flickrid and ' +
          'c.flickrid = commenter.flickrid and ' + # count only member comments
          'ph.id = g.photo_id and ' +
          'c.commented_at <= g.guessed_at and ' +
	  'c.comment_text like \'%?%\' ' +
	'group by ph.id ' +
	'order by count(*) desc, ph.dateadded',
      :page => page, :per_page => per_page)
  end

end
