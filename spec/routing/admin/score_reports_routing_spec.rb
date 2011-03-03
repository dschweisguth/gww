require 'spec_helper'

describe Admin::ScoreReportsController do
  describe 'routing' do
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
