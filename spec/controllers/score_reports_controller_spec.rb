require 'spec_helper'
require 'controllers/score_reports_controller_spec_support'

describe ScoreReportsController do
  render_views

  describe '#index' do
    it "renders the page" do
      report = ScoreReport.make :created_at => Time.local(2011)
      stub(ScoreReport).all { [ report ] }
      stub(ScoreReport).guess_counts { { report.id => 1 } }
      stub(ScoreReport).revelation_counts { { report.id => 2 } }
      get :index

      #noinspection RubyResolve
      response.should be_success
      response.should have_selector 'td', :content => 'Jan  1, 2011, 12:00 AM'
      response.should have_selector 'td', :content => '1'
      response.should have_selector 'td', :content => '2'

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
      renders_report_for @report_date, previous_report_date, :show, :id => '1'
    end

    it "uses a hardcoded previous report date for the earliest real one" do
      stub(ScoreReport).previous(@report_date.getutc) { nil }
      renders_report_for @report_date, Time.utc(2005), :show, :id => '1'
    end

  end

end
