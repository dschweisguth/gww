class Photo < ActiveRecord::Base
  belongs_to :person
  has_many :guesses
  has_many :comments
  has_one :revelation

  def page_url
    "http://www.flickr.com/photos/" + person.flickrid + "/" + flickrid +
      "/in/pool-guesswheresf/";
  end

  def image_url(size)
    "http://static.flickr.com/" + server + "/" + flickrid + "_" + secret +
      "_" + size + ".jpg"
  end

end
