class ScoreReport < ActiveRecord::Base
  belongs_to :previous_report, class_name: 'ScoreReport', inverse_of: :next_report
  has_one :next_report, class_name: 'ScoreReport', foreign_key: :previous_report_id, inverse_of: :previous_report

  def self.guess_counts
    answer_counts :guesses
  end

  def self.revelation_counts
    answer_counts :revelations
  end

  private_class_method def self.answer_counts(answer_table_name)
    reports =
      select("score_reports.*, count(*) count").
        joins("left join(score_reports previous) on (score_reports.previous_report_id = previous.id), #{answer_table_name}").
        where("ifnull(previous.created_at, ?) < #{answer_table_name}.added_at", Time.local(2005).getutc).
        where("#{answer_table_name}.added_at <= score_reports.created_at").
        group(:id)
    reports.to_h { |report| [report.id, report.count] }
  end

  def self.previous(date)
    where('created_at < ?', date.getutc).order('created_at desc').first
  end

  def self.latest
    order('id desc').first
  end

end
