require 'spec_helper'

describe Admin::RootController do
  without_transactions

  describe 'index' do
    it 'is routed to' do
      {:get => '/admin'}.should route_to :controller => 'admin/root', :action => 'index'
    end

    it 'has a named route' do
      #noinspection RubyResolve
      admin_root_path.should == '/admin'
    end

  end

  it 'routes to a plain action' do
    { :get => '/admin/bookmarklet' }.should route_to :controller => 'admin/root', :action => 'bookmarklet'
  end

end
