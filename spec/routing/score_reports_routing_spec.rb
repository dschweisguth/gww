require 'spec_helper'

describe ScoreReportsController do
  without_transactions

  describe '#index' do
    it { should have_named_route :score_reports, '/score_reports' }
    it { should route(:get, '/score_reports').to :controller => 'score_reports', :action => 'index' }
  end

  describe '#show' do
    it { should have_named_route :score_report, 666, '/score_reports/666' }
    it { should route(:get, '/score_reports/666').to :controller => 'score_reports', :action => 'show', :id => '666' }
  end

end
