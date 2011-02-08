require 'spec_helper'

describe RootController do
  describe 'routing' do
    it 'routes to index' do
      { :get => '/' }.should route_to :controller => 'root', :action => 'index'
    end

    it 'routes to other actions' do
      { :get => '/about' }.should route_to :controller => 'root', :action => 'about'
    end

  end
end
