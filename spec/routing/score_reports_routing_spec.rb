describe ScoreReportsController do

  describe '#index' do
    it { is_expected.to have_named_route :score_reports, '/score_reports' }
    it { is_expected.to route(:get, '/score_reports').to action: 'index' }
  end

  describe '#show' do
    it { is_expected.to have_named_route :score_report, 666, '/score_reports/666' }
    it { is_expected.to route(:get, '/score_reports/666').to action: 'show', id: '666' }
  end

end
