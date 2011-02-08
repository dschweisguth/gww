require 'spec_helper'

describe Admin::PhotosController do
  describe 'routing' do
    it 'routes to a plain action' do
      { :get => '/admin/photos/update' }.should route_to :controller => 'admin/photos', :action => 'update'
    end

    it 'routes to edit' do
      { :get => '/admin/photos/edit/666' }.should route_to :controller => 'admin/photos', :action => 'edit', :id => '666'
    end

  end
end
