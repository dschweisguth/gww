class Revelation < ActiveRecord::Base
  include Answer

  belongs_to :photo, inverse_of: :revelation
  validates_presence_of :comment_text, :commented_at, :added_at

  def self.longest
    order('unix_timestamp(revelations.commented_at) - unix_timestamp(photos.dateadded) desc')
      .limit(10)
      .references(:photos)
      .includes(photo: :person)
  end

  def self.all_between(from, to)
    where('? < added_at', from.getutc).where('added_at <= ?', to.getutc).includes(photo: :person)
  end

  def time_elapsed
    time_elapsed_between photo.dateadded, commented_at
  end

  def ymd_elapsed
    ymd_elapsed_between photo.dateadded, commented_at
  end

end
