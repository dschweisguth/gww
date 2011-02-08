require 'spec_helper'

describe Admin::RootController do
  describe 'routing' do
    it 'routes to index' do
      { :get => '/admin' }.should route_to :controller => 'admin/root', :action => 'index'
    end

    it 'routes to a plain action' do
      { :get => '/admin/bookmarklet' }.should route_to :controller => 'admin/root', :action => 'bookmarklet'
    end

  end
end
