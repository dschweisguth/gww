class Revelation < ActiveRecord::Base
  include Answer

  belongs_to :photo, :inverse_of => :revelation
  validates_presence_of :comment_text, :commented_at, :added_at

  #noinspection RailsParamDefResolve
  def self.longest
    all :include => { :photo => :person },
      :order => 'unix_timestamp(revelations.commented_at) - ' +
        'unix_timestamp(photos.dateadded) desc',
      :limit => 10
  end

  #noinspection RailsParamDefResolve
  def self.all_between(from, to)
    all :conditions => [ '? < added_at and added_at <= ?', from.getutc, to.getutc ],
      :include => { :photo => :person }
  end

  def time_elapsed
    #noinspection RubyResolve
    time_elapsed_between photo.dateadded, commented_at
  end

  def ymd_elapsed
    #noinspection RubyResolve
    ymd_elapsed_between photo.dateadded, commented_at
  end

end
