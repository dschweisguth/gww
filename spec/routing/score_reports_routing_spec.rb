describe ScoreReportsController do

  describe '#index' do
    it { should have_named_route :score_reports, '/score_reports' }
    it { should route(:get, '/score_reports').to action: 'index' }
  end

  describe '#show' do
    it { should have_named_route :score_report, 666, '/score_reports/666' }
    it { should route(:get, '/score_reports/666').to action: 'show', id: '666' }
  end

end
