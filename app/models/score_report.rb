class ScoreReport < ActiveRecord::Base
  def self.preceding(date)
    first :conditions => [ 'created_at < ?', date.getutc ], :order => 'created_at desc'
  end
end
