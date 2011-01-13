class Revelation < ActiveRecord::Base

  belongs_to :photo

  def self.longest
    all :include => { :photo => :person },
      :order => 'unix_timestamp(revelations.revealed_at) - ' +
        'unix_timestamp(photos.dateadded) desc',
      :limit => 10
  end

end
