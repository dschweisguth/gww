require 'spec_helper'

describe RootController do
  describe 'routing' do
    describe 'root' do
      it 'is routed to' do
        {:get => '/'}.should route_to :controller => 'root', :action => 'index'
      end

      it 'has a named route' do
        root_path.should == '/'
      end

    end

    it 'routes to a plain action' do
      { :get => '/about' }.should route_to :controller => 'root', :action => 'about'
    end

  end
end
