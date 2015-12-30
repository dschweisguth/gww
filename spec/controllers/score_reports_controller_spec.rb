require 'controllers/score_reports_controller_spec_support'

describe ScoreReportsController do
  render_views

  describe '#index' do
    it "renders the page" do
      report = build_stubbed :score_report, created_at: Time.local(2011)
      allow(ScoreReport).to receive(:order) { [ report ] }
      allow(ScoreReport).to receive(:guess_counts) { { report.id => 1 } }
      allow(ScoreReport).to receive(:revelation_counts) { { report.id => 2 } }
      get :index

      expect(response).to be_success
      expect(response.body).to have_css 'td', text: 'Jan  1, 2011, 12:00 AM'
      expect(response.body).to have_css 'td', text: '1'
      expect(response.body).to have_css 'td', text: '2'

    end
  end

  describe '#show' do
    before do
      @report_date = Time.local(2011, 1, 5)
      allow(ScoreReport).to receive(:find).with('1') { build_stubbed :score_report, created_at: @report_date.getutc }
    end

    it "renders the page" do
      previous_report_date = Time.local(2011).getutc
      previous_report = build_stubbed :score_report, created_at: previous_report_date
      allow(ScoreReport).to receive(:previous).with(@report_date.getutc) { previous_report }
      renders_report_for @report_date, previous_report_date, :show, id: '1'
    end

    it "uses a hardcoded previous report date for the earliest real one" do
      allow(ScoreReport).to receive(:previous).with(@report_date.getutc) { nil }
      renders_report_for @report_date, Time.utc(2005), :show, id: '1'
    end

  end

end
