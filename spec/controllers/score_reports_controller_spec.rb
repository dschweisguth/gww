require 'spec_helper'
require 'controllers/score_reports_controller_spec_support'

describe ScoreReportsController do
  integrate_views
  without_transactions

  describe '#index' do
    it "renders the page" do
      report = ScoreReport.make :created_at => Time.local(2011)
      stub(ScoreReport).all { [ report ] }
      guess_count_report = report.dup
      guess_count_report[:count] = 1
      stub(ScoreReport).all_with_guess_counts { [ guess_count_report ] }
      revelation_count_report = report.dup
      revelation_count_report[:count] = 2
      stub(ScoreReport).all_with_revelation_counts { [ revelation_count_report ] }
      get :index

      #noinspection RubyResolve
      response.should be_success
      p response.body
      response.should have_tag 'td', :text => 'Jan  1, 2011, 12:00 AM'
#      response.should have_tag 'td', :text => '1' # TODO Dave fix this
      response.should have_tag 'td', :text => '2'

    end
  end

  describe '#show' do
    before do
      @report_date = Time.local(2011, 1, 5)
      stub(ScoreReport).find('1') { ScoreReport.make :created_at => @report_date.getutc }
    end

    it "renders the page" do
      previous_report_date = Time.local(2011).getutc
      previous_report = ScoreReport.make :created_at => previous_report_date
      stub(ScoreReport).previous(@report_date.getutc) { previous_report }
      should_render_report_for @report_date, previous_report_date, :show, :id => 1
    end

    it "uses a hardcoded previous report date for the earliest real one" do
      stub(ScoreReport).previous(@report_date.getutc) { nil }
      should_render_report_for @report_date, Time.utc(2005), :show, :id => 1
    end

  end

end
