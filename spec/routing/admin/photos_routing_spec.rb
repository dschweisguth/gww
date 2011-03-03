require 'spec_helper'

describe Admin::PhotosController do
    describe 'edit' do
      it 'is routed to' do
        { :get => '/admin/photos/edit/666' }.should route_to :controller => 'admin/photos', :action => 'edit', :id => '666'
      end

      it 'has a named route' do
        #noinspection RubyResolve
        edit_photo_path(666).should == '/admin/photos/edit/666'
      end

    end

    it 'routes to a plain action' do
      { :get => '/admin/photos/update' }.should route_to :controller => 'admin/photos', :action => 'update'
    end

end
