class ScoreReport < ActiveRecord::Base
  belongs_to :previous_report, :class_name => 'ScoreReport'
  #noinspection RailsParamDefResolve
  has_one :next_report, :class_name => 'ScoreReport', :foreign_key => :previous_report_id

  def self.previous(date)
    first :conditions => [ 'created_at < ?', date.getutc ], :order => 'created_at desc'
  end

end
