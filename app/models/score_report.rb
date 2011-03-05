class ScoreReport < ActiveRecord::Base
  belongs_to :previous_report, :class_name => 'ScoreReport'
  #noinspection RailsParamDefResolve
  has_one :next_report, :class_name => 'ScoreReport', :foreign_key => :previous_report_id

  def self.all_with_guess_counts
    all_with_answer_counts :guesses
  end

  def self.all_with_revelation_counts
    all_with_answer_counts :revelations
  end

  def self.all_with_answer_counts(answer_table_name)
    find_by_sql [
      %Q[
        select current.*, count(*) count
        from score_reports current
          left join(score_reports previous) on (current.previous_report_id = previous.id),
          #{answer_table_name} a
        where ifnull(previous.created_at, ?) < a.added_at and a.added_at <= current.created_at
        group by current.id
      ],
      Time.local(2005).getutc
    ]
  end
  private_class_method :all_with_answer_counts

  def self.previous(date)
    first :conditions => [ 'created_at < ?', date.getutc ], :order => 'created_at desc'
  end

end
