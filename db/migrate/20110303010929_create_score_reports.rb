class CreateScoreReports < ActiveRecord::Migration
  def self.up
    create_table :score_reports do |t|
      t.datetime :created_at
    end
    ScoreReport.create! :created_at => Time.local(2011, 2, 26, 20, 0, 0)
  end

  def self.down
    drop_table :score_reports
  end

end
