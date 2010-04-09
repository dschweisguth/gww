class FlickrUpdate < ActiveRecord::Base

  def self.latest
    find(:first, :order => "id desc")
  end

end
