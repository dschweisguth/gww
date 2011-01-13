class Revelation < ActiveRecord::Base
  include Answer

  belongs_to :photo

  def self.longest
    all :include => { :photo => :person },
      :order => 'unix_timestamp(revelations.revealed_at) - ' +
        'unix_timestamp(photos.dateadded) desc',
      :limit => 10
  end

  def time_elapsed
    time_elapsed_between photo.dateadded, revealed_at
  end

  def ymd_elapsed
    ymd_elapsed_between photo.dateadded, revealed_at
  end

end
