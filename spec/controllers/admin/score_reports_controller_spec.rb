require 'controllers/score_reports_controller_spec_support'

describe Admin::ScoreReportsController do
  describe '#index' do
    it "renders the page" do
      report2 = build_stubbed :score_report, created_at: Time.local(2011, 1, 2)
      report1 = build_stubbed :score_report, created_at: Time.local(2011)
      allow(ScoreReport).to receive(:order) { [report2, report1] }
      allow(ScoreReport).to receive(:guess_counts) { { report2.id => 4, report1.id => 3 } }
      allow(ScoreReport).to receive(:revelation_counts) { { report2.id => 1 } }
      allow(Time).to receive(:now) { Time.local(2011, 1, 2) }
      get :index

      expect(response).to be_success
      trs = top_node.all 'tr'

      expect(trs[1]).to have_css 'a', text: 'Jan  2, 2011, 12:00 AM'
      expect(trs[1]).to have_css 'td', text: '4'
      expect(trs[1]).to have_css 'td', text: '1'
      expect(trs[1]).to have_css 'form'

      expect(trs[2]).to have_css 'a', text: 'Jan  1, 2011, 12:00 AM'
      expect(trs[2]).to have_css 'td', text: '1'
      expect(trs[2]).to have_css 'td', text: '0' # the page filled in the missing revelation count

    end

    it "doesn't allow deletion of the last report" do
      allow(ScoreReport).to receive(:order) { [build_stubbed(:score_report, created_at: Time.now)] }
      allow(ScoreReport).to receive(:guess_counts).and_return({})
      allow(ScoreReport).to receive(:revelation_counts).and_return({})
      get :index

      expect(response).to be_success
      expect(response).not_to have_css 'form'

    end

    it "doesn't allow deletion of a report more than a day old" do
      allow(ScoreReport).to receive(:order) { [build_stubbed(:score_report, created_at: Time.now - 1.day - 1.second)] }
      allow(ScoreReport).to receive(:guess_counts).and_return({})
      allow(ScoreReport).to receive(:revelation_counts).and_return({})
      get :index

      expect(response).to be_success
      expect(response).not_to have_css 'form'

    end

  end

  describe '#new' do
    let(:report_date) { Time.local(2011, 1, 5) }

    before do
      allow(Time).to receive(:now) { report_date }
    end

    it "renders the page" do
      previous_report_date = Time.local(2011).getutc
      previous_report = build_stubbed :score_report, created_at: previous_report_date
      allow(ScoreReport).to receive(:previous).with(report_date.getutc) { previous_report }
      renders_report_for report_date, previous_report_date, :new
    end

    it "uses a hardcoded previous report date for the earliest real one" do
      allow(ScoreReport).to receive(:previous).with(report_date.getutc).and_return(nil)
      renders_report_for report_date, Time.utc(2005), :new
    end

  end

  describe '#create' do
    it "creates and redirects" do
      previous = build_stubbed :score_report
      allow(ScoreReport).to receive(:latest) { previous }
      allow(ScoreReport).to receive(:create!).with previous_report: previous
      allow_clear_page_cache
      post :create

      expect(ScoreReport).to have_received(:create!).with previous_report: previous
      expect_clear_page_cache
      expect(response).to redirect_to admin_score_reports_path

    end
  end

  describe '#destroy' do
    it "destroys and redirects" do
      allow(ScoreReport).to receive(:destroy).with '666'
      allow_clear_page_cache
      get :destroy, id: '666'

      expect(ScoreReport).to have_received(:destroy).with '666'
      expect_clear_page_cache
      expect(response).to redirect_to admin_score_reports_path

    end
  end

end
