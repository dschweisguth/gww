require 'spec_helper'

describe Admin::PhotosController do
  without_transactions

  describe 'update' do
    it 'is routed to' do
      { :post => '/admin/photos/update' }.should route_to :controller => 'admin/photos', :action => 'update'
    end

    it 'has a named route' do
      #noinspection RubyResolve
      update_photos_path.should == '/admin/photos/update'
    end
    
  end

  describe 'update_statistics' do
    it 'is routed to' do
      { :post => '/admin/photos/update_statistics' }.should route_to :controller => 'admin/photos', :action => 'update_statistics'
    end

    it 'has a named route' do
      #noinspection RubyResolve
      update_photo_statistics_path.should == '/admin/photos/update_statistics'
    end

  end

  describe 'edit' do
    it 'is routed to' do
      { :get => '/admin/photos/edit/666' }.should route_to :controller => 'admin/photos', :action => 'edit', :id => '666'
    end

    it 'has a named route' do
      #noinspection RubyResolve
      edit_photo_path(666).should == '/admin/photos/edit/666'
    end

  end

  # TODO Dave after adding more RESTful and named routes, either remove these or use current examples

  it 'routes to a plain action' do
    { :get => '/admin/photos/update' }.should route_to :controller => 'admin/photos', :action => 'update'
  end

  it 'routes to a plain action with an ID' do
    { :get => '/admin/photos/add_answer/666' }.should route_to :controller => 'admin/photos', :action => 'add_answer', :id => '666'
  end

end
