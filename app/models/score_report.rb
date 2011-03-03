class ScoreReport < ActiveRecord::Base
  def self.preceding(date)
    first :conditions => [ 'created_at < ?', date ], :order => 'created_at desc'
  end
end
