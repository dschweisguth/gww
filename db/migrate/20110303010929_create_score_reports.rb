class CreateScoreReports < ActiveRecord::Migration
  def self.up
    create_table :score_reports do |t|
      t.datetime :created_at
    end
    if RAILS_ENV != 'test'
      ScoreReport.create! :created_at => Time.local(2011, 2, 26, 20, 0, 0)
    end
  end

  def self.down
    drop_table :score_reports
  end

end
