require 'controllers/score_reports_controller_spec_support'

describe ScoreReportsController do
  describe '#index' do
    it "renders the page" do
      report = build_stubbed :score_report, created_at: Time.local(2011)
      allow(ScoreReport).to receive(:order).and_return([report])
      allow(ScoreReport).to receive(:guess_counts).and_return(report.id => 1)
      allow(ScoreReport).to receive(:revelation_counts).and_return(report.id => 2)
      get :index

      expect(response).to be_success
      expect(response.body).to have_css 'td', text: 'Jan  1, 2011, 12:00 AM'
      expect(response.body).to have_css 'td', text: '1'
      expect(response.body).to have_css 'td', text: '2'

    end
  end

  describe '#show' do
    let(:report_date) { Time.local(2011, 1, 5) }

    before do
      allow(ScoreReport).to receive(:find).with('1').and_return(build_stubbed :score_report, created_at: report_date.getutc)
    end

    it "shows a report with all scores" do
      previous_report_date = Time.local(2011).getutc
      previous_report = build_stubbed :score_report, created_at: previous_report_date
      allow(ScoreReport).to receive(:previous).with(report_date.getutc).and_return(previous_report)
      renders_report_for report_date, previous_report_date, :show, id: '1'
    end

    it "shows a report with no scores" do
      previous_report_date = Time.local(2011).getutc
      previous_report = build_stubbed :score_report, created_at: previous_report_date
      allow(ScoreReport).to receive(:previous).with(report_date.getutc).and_return(previous_report)

      allow(ScoreReportsGuess).to receive(:all_between).with(previous_report_date, report_date.getutc).and_return([])
      allow(Revelation).to receive(:all_between).with(previous_report_date, report_date.getutc).and_return([])

      allow(ScoreReportsPerson).to receive(:high_scorers).with(report_date, 7).and_return([])
      allow(ScoreReportsPerson).to receive(:high_scorers).with(report_date, 30).and_return([])

      allow(ScoreReportsPerson).to receive(:top_posters).with(report_date, 7).and_return([])
      allow(ScoreReportsPerson).to receive(:top_posters).with(report_date, 30).and_return([])

      allow(ScoreReportsPhoto).to receive(:count_between).with(previous_report_date, report_date.getutc).and_return(0)
      allow(ScoreReportsPhoto).to receive(:unfound_or_unconfirmed_count_before).with(report_date).and_return(0)

      allow(ScoreReportsPerson).to receive(:all_before).with(report_date).and_return([])

      allow(ScoreReportsPhoto).to receive(:add_posts).with([], report_date, :post_count)
      allow(ScoreReportsPerson).to receive(:by_score).with([], report_date).and_return({})
      allow(ScoreReportsPerson).to receive(:add_change_in_standings).with({}, [], previous_report_date, [])

      allow(FlickrUpdate).to receive(:latest).and_return(build_stubbed :flickr_update, member_count: 0)

      get :show, id: '1'

      expect(response.body).not_to match(/new guesses by .../)
      expect(response.body).not_to match(/photos revealed by .../)
    end

    it "uses a hardcoded previous report date for the earliest real one" do
      allow(ScoreReport).to receive(:previous).with(report_date.getutc).and_return(nil)
      renders_report_for report_date, Time.utc(2005), :show, id: '1'
    end

  end

end
