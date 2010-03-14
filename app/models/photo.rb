class Photo < ActiveRecord::Base
  belongs_to :person
  has_many :guesses
  has_many :comments
  has_one :revelation

  def self.update_seen_at(flickrids, time)
    joined_flickrids = flickrids.map { |flickrid| "'#{flickrid}'" }.join ','
    Photo.update_all("seen_at = '#{time.strftime '%Y-%m-%d %H:%M:%S'}'",
      "flickrid in (#{joined_flickrids})")
  end

  def page_url
    "http://www.flickr.com/photos/#{person.flickrid}/#{flickrid}/in/pool-guesswheresf/";
  end

  def image_url(size)
    "http://#{farm.empty? ? "" : "farm#{farm}."}static.flickr.com/#{server}/#{flickrid}_#{secret}_#{size}.jpg"
  end

end
