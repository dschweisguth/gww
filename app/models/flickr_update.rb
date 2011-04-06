class FlickrUpdate < ActiveRecord::Base
  validates_presence_of :member_count
  validates_numericality_of :member_count, :only_integer => true,
    :greater_than_or_equal_to => 0
  attr_readonly :member_count

  def self.latest
    order("id desc").first
  end

end
