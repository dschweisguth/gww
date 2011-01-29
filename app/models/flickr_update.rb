class FlickrUpdate < ActiveRecord::Base
  validates_presence_of :member_count
  attr_readonly :member_count

  def self.latest
    find :first, :order => "id desc"
  end

end
