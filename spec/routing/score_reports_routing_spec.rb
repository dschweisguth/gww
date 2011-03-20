require 'spec_helper'

describe ScoreReportsController do
  without_transactions

  describe '#index' do
    it 'has a named route' do
      #noinspection RubyResolve
      score_reports_path.should == '/score_reports'
    end

    it { should route(:get, '/score_reports').to :controller => 'score_reports', :action => 'index' }

  end

  describe '#show' do
    it 'has a named route' do
      #noinspection RubyResolve
      score_report_path('666').should == '/score_reports/666'
    end

    it { should route(:get, '/score_reports/666').to :controller => 'score_reports', :action => 'show', :id => '666' }

  end

end
