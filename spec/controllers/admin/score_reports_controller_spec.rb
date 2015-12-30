require 'controllers/score_reports_controller_spec_support'

describe Admin::ScoreReportsController do
  render_views

  describe '#index' do
    it "renders the page" do
      report2 = build_stubbed :score_report, created_at: Time.local(2011, 1, 2)
      report1 = build_stubbed :score_report, created_at: Time.local(2011)
      allow(ScoreReport).to receive(:order) { [ report2, report1 ] }
      allow(ScoreReport).to receive(:guess_counts) { { report2.id => 4, report1.id => 3 } }
      allow(ScoreReport).to receive(:revelation_counts) { { report2.id => 1 } }
      allow(Time).to receive(:now) { Time.local(2011, 1, 2) }
      get :index

      response.should be_success
      trs = top_node.all 'tr'

      trs[1].should have_css 'a', text: 'Jan  2, 2011, 12:00 AM'
      trs[1].should have_css 'td', text: '4'
      trs[1].should have_css 'td', text: '1'
      trs[1].should have_css 'form'

      trs[2].should have_css 'a', text: 'Jan  1, 2011, 12:00 AM'
      trs[2].should have_css 'td', text: '1'
      trs[2].should have_css 'td', text: '0' # the page filled in the missing revelation count

    end

    it "doesn't allow deletion of the last report" do
      allow(ScoreReport).to receive(:order) { [ build_stubbed(:score_report, created_at: Time.now) ] }
      allow(ScoreReport).to receive(:guess_counts) { {} }
      allow(ScoreReport).to receive(:revelation_counts) { {} }
      get :index

      response.should be_success
      response.should_not have_css 'form'

    end

    it "doesn't allow deletion of a report more than a day old" do
      allow(ScoreReport).to receive(:order) { [ build_stubbed(:score_report, created_at: Time.now - 1.day - 1.second) ] }
      allow(ScoreReport).to receive(:guess_counts) { {} }
      allow(ScoreReport).to receive(:revelation_counts) { {} }
      get :index

      response.should be_success
      response.should_not have_css 'form'

    end

  end

  describe '#new' do
    before do
      @report_date = Time.local(2011, 1, 5)
      allow(Time).to receive(:now) { @report_date }
    end

    it "renders the page" do
      previous_report_date = Time.local(2011).getutc
      previous_report = build_stubbed :score_report, created_at: previous_report_date
      allow(ScoreReport).to receive(:previous).with(@report_date.getutc) { previous_report }
      renders_report_for @report_date, previous_report_date, :new
    end

    it "uses a hardcoded previous report date for the earliest real one" do
      allow(ScoreReport).to receive(:previous).with(@report_date.getutc) { nil }
      renders_report_for @report_date, Time.utc(2005), :new
    end

  end

  describe '#create' do
    it "creates and redirects" do
      previous = build_stubbed :score_report
      allow(ScoreReport).to receive(:latest) { previous }
      expect(ScoreReport).to receive(:create!).with previous_report: previous
      mock_clear_page_cache
      post :create

      response.should redirect_to admin_score_reports_path

    end
  end

  describe '#destroy' do
    it "destroys and redirects" do
      expect(ScoreReport).to receive(:destroy).with '666'
      mock_clear_page_cache
      get :destroy, id: '666'

      response.should redirect_to admin_score_reports_path

    end
  end

end
