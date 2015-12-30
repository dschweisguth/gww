describe Admin::ScoreReportsController do

  describe '#index, #create' do
    it { is_expected.to have_named_route :admin_score_reports, '/admin/score_reports' }
  end

  describe '#index' do
    it { is_expected.to route(:get, '/admin/score_reports').to controller: 'admin/score_reports', action: 'index' }
  end

  describe '#new' do
    it { is_expected.to have_named_route :new_admin_score_report, '/admin/score_reports/new' }
    it { is_expected.to route(:get, '/admin/score_reports/new').to controller: 'admin/score_reports', action: 'new' }
  end

  describe '#create' do
    it { is_expected.to route(:post, '/admin/score_reports').to controller: 'admin/score_reports', action: 'create' }
  end

  describe '#destroy' do
    it { is_expected.to have_named_route :admin_score_report, 666, '/admin/score_reports/666' }
    it { is_expected.to route(:delete, '/admin/score_reports/666').to controller: 'admin/score_reports', action: 'destroy', id: '666' }
  end

end
