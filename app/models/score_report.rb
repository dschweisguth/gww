class ScoreReport < ActiveRecord::Base
  belongs_to :previous_report, :class_name => 'ScoreReport', :inverse_of => :next_report
  has_one :next_report, :class_name => 'ScoreReport', :foreign_key => :previous_report_id, :inverse_of => :previous_report

  def self.guess_counts
    answer_counts :guesses
  end

  def self.revelation_counts
    answer_counts :revelations
  end

  def self.answer_counts(answer_table_name)
    reports = find_by_sql [
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
    Hash[reports.map { |report| [ report.id, report[:count] ] }]
  end
  private_class_method :answer_counts

  def self.previous(date)
    first :conditions => [ 'created_at < ?', date.getutc ], :order => 'created_at desc'
  end

end
