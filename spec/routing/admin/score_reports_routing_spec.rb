require 'spec_helper'

describe Admin::ScoreReportsController do
  without_transactions

  describe '#index, #create' do
    it 'has a named route' do
      #noinspection RubyResolve
      admin_score_reports_path.should == '/admin/score_reports'
    end
  end

  describe '#index' do
    it { should route(:get, '/admin/score_reports').to :controller => 'admin/score_reports', :action => 'index' }
  end

  describe '#new' do
    it 'has a named route' do
      #noinspection RubyResolve
      new_admin_score_report_path.should == '/admin/score_reports/new'
    end

    it { should route(:get, '/admin/score_reports/new').to :controller => 'admin/score_reports', :action => 'new' }

  end

  describe '#create' do
    it { should route(:post, '/admin/score_reports').to :controller => 'admin/score_reports', :action => 'create' }
  end

  describe '#destroy' do
    it 'has a named route' do
      #noinspection RubyResolve
      admin_score_report_path('666').should == '/admin/score_reports/666'
    end

    it { should route(:delete, '/admin/score_reports/666').to :controller => 'admin/score_reports', :action => 'destroy', :id => '666' }

  end

end
