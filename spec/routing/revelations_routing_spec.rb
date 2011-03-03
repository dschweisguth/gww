require 'spec_helper'

describe RevelationsController do
  it 'routes to a plain action' do
    { :get => '/revelations/longest' }.should route_to :controller => 'revelations', :action => 'longest'
  end
end
