require 'spec_helper'

describe Admin::ScoreReportsController do

  describe '#index, #create' do
    it { should have_named_route :admin_score_reports, '/admin/score_reports' }
  end

  describe '#index' do
    it { should route(:get, '/admin/score_reports').to controller: 'admin/score_reports', action: 'index' }
  end

  describe '#new' do
    it { should have_named_route :new_admin_score_report, '/admin/score_reports/new' }
    it { should route(:get, '/admin/score_reports/new').to controller: 'admin/score_reports', action: 'new' }
  end

  describe '#create' do
    it { should route(:post, '/admin/score_reports').to controller: 'admin/score_reports', action: 'create' }
  end

  describe '#destroy' do
    it { should have_named_route :admin_score_report, 666, '/admin/score_reports/666' }
    it { should route(:delete, '/admin/score_reports/666').to controller: 'admin/score_reports', action: 'destroy', id: '666' }
  end

end
