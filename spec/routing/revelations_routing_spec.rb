require 'spec_helper'

describe RevelationsController do
  describe 'routing' do
    it 'routes to an action' do
      { :get => '/revelations/longest' }.should route_to :controller => 'revelations', :action => 'longest'
    end
  end
end
