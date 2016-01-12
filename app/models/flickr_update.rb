class FlickrUpdate < ActiveRecord::Base
  validates :member_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  attr_readonly :member_count

  def self.latest
    order("id desc").first
  end

end
