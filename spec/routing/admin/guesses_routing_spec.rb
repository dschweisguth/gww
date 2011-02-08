require 'spec_helper'

describe Admin::GuessesController do
  describe 'routing' do
    it 'routes to a plain action' do
      { :get => '/admin/guesses/report' }.should route_to :controller => 'admin/guesses', :action => 'report'
    end
  end
end
