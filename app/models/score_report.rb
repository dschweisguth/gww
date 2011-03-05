class ScoreReport < ActiveRecord::Base
  belongs_to :previous_report, :class_name => 'ScoreReport'
  #noinspection RailsParamDefResolve
  has_one :next_report, :class_name => 'ScoreReport', :foreign_key => :previous_report_id

  def self.all_with_guess_counts
    find_by_sql [
      %q[
        select current.*, count(*) count
        from score_reports current
          left join(score_reports previous) on (current.previous_report_id = previous.id),
          guesses g
        where ifnull(previous.created_at, ?) < g.added_at and g.added_at <= current.created_at
        group by current.id
      ],
      Time.local(2005).getutc
    ]
  end

  def self.previous(date)
    first :conditions => [ 'created_at < ?', date.getutc ], :order => 'created_at desc'
  end

end
