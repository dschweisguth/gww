require 'spec_helper'

describe Admin::ScoreReportsController do
  describe 'routing' do
    describe 'new' do
      it 'is routed to' do
        { :get => '/admin/score_reports/new' }.should route_to :controller => 'admin/score_reports', :action => 'new'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        new_score_report_path.should == '/admin/score_reports/new'
      end

    end

    describe 'create' do
      it 'is routed to' do
        { :post => '/admin/score_reports' }.should route_to :controller => 'admin/score_reports', :action => 'create'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        score_reports_path.should == '/admin/score_reports'
      end

    end

  end
end
