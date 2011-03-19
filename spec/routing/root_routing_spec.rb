require 'spec_helper'

describe RootController do
  without_transactions

  describe 'root' do
    it 'has a named route' do
      root_path.should == '/'
    end

    it 'is routed to' do
      { :get => '/' }.should route_to :controller => 'root', :action => 'index'
    end

  end

  it 'routes to a plain action' do
    { :get => '/about' }.should route_to :controller => 'root', :action => 'about'
  end

end
