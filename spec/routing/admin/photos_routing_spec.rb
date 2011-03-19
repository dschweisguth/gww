require 'spec_helper'

describe Admin::PhotosController do
  without_transactions

  describe 'update' do
    it 'has a named route' do
      #noinspection RubyResolve
      update_photos_path.should == '/admin/photos/update'
    end
    
    it 'is routed to' do
      { :post => '/admin/photos/update' }.should route_to :controller => 'admin/photos', :action => 'update'
    end

  end

  describe 'update_statistics' do
    it 'has a named route' do
      #noinspection RubyResolve
      update_photo_statistics_path.should == '/admin/photos/update_statistics'
    end

    it 'is routed to' do
      { :post => '/admin/photos/update_statistics' }.should route_to :controller => 'admin/photos', :action => 'update_statistics'
    end

  end

  describe 'unfound' do
    it 'has a named route' do
      #noinspection RubyResolve
      unfound_admin_photos_path.should == '/admin/photos/unfound'
    end

    it 'is routed to' do
      { :get => '/admin/photos/unfound' }.should route_to :controller => 'admin/photos', :action => 'unfound'
    end

  end

  describe 'inaccessible' do
    it 'has a named route' do
      #noinspection RubyResolve
      inaccessible_admin_photos_path.should == '/admin/photos/inaccessible'
    end

    it 'is routed to' do
      { :get => '/admin/photos/inaccessible' }.should route_to :controller => 'admin/photos', :action => 'inaccessible'
    end

  end

  describe 'multipoint' do
    it 'has a named route' do
      #noinspection RubyResolve
      multipoint_admin_photos_path.should == '/admin/photos/multipoint'
    end

    it 'is routed to' do
      { :get => '/admin/photos/multipoint' }.should route_to :controller => 'admin/photos', :action => 'multipoint'
    end

  end

  describe 'edit' do
    it 'has a named route' do
      #noinspection RubyResolve
      edit_admin_photo_path(666).should == '/admin/photos/666/edit'
    end

    it 'is routed to' do
      { :get => '/admin/photos/666/edit' }.should route_to :controller => 'admin/photos', :action => 'edit', :id => '666'
    end

  end

  %w{ change_game_status add_selected_answer add_entered_answer remove_revelation remove_guess reload_comments }.each do |action|
    describe action do
      it 'has a named route' do
        eval("#{action}_path(666)").should == "/admin/photos/666/#{action}"
      end

      it 'is routed to' do
        { :post => "/admin/photos/666/#{action}" }.should route_to :controller => 'admin/photos', :action => action, :id => '666'
      end

    end
  end

  describe 'destroy' do
    it 'has a named route' do
      #noinspection RubyResolve
      admin_photo_path(666).should == '/admin/photos/666'
    end

    it 'is routed to' do
      { :delete => '/admin/photos/666' }.should route_to :controller => 'admin/photos', :action => 'destroy', :id => '666'
    end

  end

  describe 'edit_in_gww' do
    it 'has a named route' do
      #noinspection RubyResolve
      edit_in_gww_path.should == '/admin/photos/edit_in_gww'
    end

    it 'is routed to' do
      { :get => '/admin/photos/edit_in_gww' }.should route_to :controller => 'admin/photos', :action => 'edit_in_gww'
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
