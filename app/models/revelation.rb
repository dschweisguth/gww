class Revelation < ActiveRecord::Base
  include Answer

  belongs_to :photo
  validates_presence_of :revelation_text, :revealed_at, :added_at
  attr_readonly :revelation_text, :revealed_at, :added_at

  #noinspection RailsParamDefResolve
  def self.longest
    all :include => { :photo => :person },
      :order => 'unix_timestamp(revelations.revealed_at) - ' +
        'unix_timestamp(photos.dateadded) desc',
      :limit => 10
  end

  #noinspection RailsParamDefResolve
  def self.all_since(update)
    @revelations = Revelation.all \
      :conditions => [ "added_at > ?", update.created_at ],
      :include => { :photo => :person }
  end

  def time_elapsed
    time_elapsed_between photo.dateadded, revealed_at
  end

  def ymd_elapsed
    ymd_elapsed_between photo.dateadded, revealed_at
  end

end
